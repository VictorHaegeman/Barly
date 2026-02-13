-- Production readiness check - 2026-02-13
-- Read-only diagnostics. Safe to run multiple times.

with
  ext as (
    select exists (
      select 1 from pg_extension where extname = 'pgcrypto'
    ) as pgcrypto_installed
  ),
  fn as (
    select to_regprocedure('public.join_private_event(uuid,text)') as regproc
  ),
  fn_def as (
    select
      regproc,
      case
        when regproc is not null then pg_get_functiondef(regproc)
        else null
      end as body
    from fn
  ),
  checks as (
    select
      (not has_column_privilege('anon', 'public.events', 'access_code_hash', 'select')) as anon_hash_hidden,
      (not has_column_privilege('authenticated', 'public.events', 'access_code_hash', 'select')) as auth_hash_hidden,
      has_column_privilege('service_role', 'public.events', 'access_code_hash', 'select') as service_role_hash_allowed,
      exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'events'
          and policyname = 'events read'
      ) as events_read_policy_exists,
      exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename = 'events'
          and policyname = 'events update owner'
      ) as events_update_owner_policy_exists,
      exists (
        select 1
        from pg_policies
        where schemaname = 'storage'
          and tablename = 'objects'
          and policyname = 'avatars auth insert'
      ) as avatars_insert_policy_exists,
      exists (
        select 1
        from pg_policies
        where schemaname = 'storage'
          and tablename = 'objects'
          and policyname = 'avatars auth update'
      ) as avatars_update_policy_exists,
      exists (
        select 1
        from pg_policies
        where schemaname = 'storage'
          and tablename = 'objects'
          and policyname = 'avatars auth delete'
      ) as avatars_delete_policy_exists,
      (select pgcrypto_installed from ext) as pgcrypto_installed,
      (select regproc is not null from fn) as join_private_event_exists,
      coalesce(
        (
          select
            position('sha256''::text' in body) > 0
            or (
              position('digest(' in lower(body)) > 0
              and position('sha256' in lower(body)) > 0
            )
          from fn_def
        ),
        false
      ) as join_private_event_uses_sha256_text_cast,
      coalesce(
        (
          select position('format(' in body) > 0
          from fn_def
        ),
        false
      ) as join_private_event_uses_dynamic_schema_digest
  )
select
  *,
  (
    anon_hash_hidden
    and auth_hash_hidden
    and service_role_hash_allowed
    and events_read_policy_exists
    and events_update_owner_policy_exists
    and avatars_insert_policy_exists
    and avatars_update_policy_exists
    and avatars_delete_policy_exists
    and pgcrypto_installed
    and join_private_event_exists
    and join_private_event_uses_sha256_text_cast
    and join_private_event_uses_dynamic_schema_digest
  ) as all_green
from checks;
