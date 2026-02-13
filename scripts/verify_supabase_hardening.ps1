param(
  [Parameter(Mandatory = $false)]
  [string]$SupabaseUrl = $env:SUPABASE_URL,

  [Parameter(Mandatory = $false)]
  [string]$AnonKey = $env:SUPABASE_ANON_KEY,

  [Parameter(Mandatory = $false)]
  [string]$Password = "BarlyCheck#2026!"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SupabaseUrl) -or [string]::IsNullOrWhiteSpace($AnonKey)) {
  throw "Missing SUPABASE_URL or SUPABASE_ANON_KEY. Pass parameters or set env vars."
}

if ($SupabaseUrl.EndsWith("/")) {
  $SupabaseUrl = $SupabaseUrl.TrimEnd("/")
}

function Invoke-Supa {
  param(
    [string]$Method,
    [string]$Path,
    [object]$Body = $null,
    [string]$Token = $null
  )

  $headers = @{ apikey = $AnonKey }
  if ($Token) {
    $headers["Authorization"] = "Bearer $Token"
  }

  $request = @{
    Method = $Method
    Uri = "$SupabaseUrl$Path"
    Headers = $headers
    ErrorAction = "Stop"
  }

  if ($null -ne $Body) {
    $request["Body"] = ($Body | ConvertTo-Json -Compress -Depth 20)
    $request["ContentType"] = "application/json"
  }

  try {
    $response = Invoke-RestMethod @request
    return [pscustomobject]@{
      ok = $true
      status = 200
      raw = ""
      body = $response
    }
  } catch {
    $status = 0
    $raw = ""
    try {
      if ($_.Exception.Response) {
        $status = [int]$_.Exception.Response.StatusCode
        $sr = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
        $raw = $sr.ReadToEnd()
      }
    } catch {}
    return [pscustomobject]@{
      ok = $false
      status = $status
      raw = $raw
      body = $null
    }
  }
}

$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$email = "preprodcheck+$ts@example.com"

$signUp = Invoke-Supa -Method "POST" -Path "/auth/v1/signup" -Body @{
  email = $email
  password = $Password
}

if (-not $signUp.ok -or -not $signUp.body.access_token) {
  $signUp = Invoke-Supa -Method "POST" -Path "/auth/v1/token?grant_type=password" -Body @{
    email = $email
    password = $Password
  }
}

$token = $signUp.body.access_token
$uid = if ($signUp.body -and $signUp.body.user) { $signUp.body.user.id } else { $null }

$anonHash = Invoke-Supa -Method "GET" -Path "/rest/v1/events?select=id,access_code_hash&limit=1"
$authedHash = Invoke-Supa -Method "GET" -Path "/rest/v1/events?select=id,access_code_hash&limit=1" -Token $token
$rpcPrivate = Invoke-Supa -Method "POST" -Path "/rest/v1/rpc/join_private_event" -Body @{
  p_event_id = "00000000-0000-0000-0000-000000000000"
  p_code = "123456"
} -Token $token
$rpcPublic = Invoke-Supa -Method "POST" -Path "/rest/v1/rpc/join_event" -Body @{
  p_event_id = "00000000-0000-0000-0000-000000000000"
} -Token $token

$storageOwnUpload = $null
$storageOtherUpload = $null
$storageOwnDelete = $null

if ($token -and $uid) {
  $ownPath = "$uid/verify-$ts.txt"
  $otherPath = "00000000-0000-0000-0000-000000000000/verify-$ts.txt"
  $storageOwnUpload = Invoke-Supa -Method "POST" -Path "/storage/v1/object/avatars/$ownPath" -Body "ok" -Token $token
  $storageOtherUpload = Invoke-Supa -Method "POST" -Path "/storage/v1/object/avatars/$otherPath" -Body "nope" -Token $token
  $storageOwnDelete = Invoke-Supa -Method "DELETE" -Path "/storage/v1/object/avatars/$ownPath" -Token $token
}

[ordered]@{
  checks = [ordered]@{
    access_code_hash_blocked_anon = (-not $anonHash.ok)
    access_code_hash_blocked_authenticated = (-not $authedHash.ok)
    join_private_rpc_deployed = ($rpcPrivate.status -ne 404)
    join_public_rpc_deployed = ($rpcPublic.status -ne 404)
    storage_own_upload_ok = ($storageOwnUpload -ne $null -and $storageOwnUpload.ok)
    storage_other_upload_blocked = ($storageOtherUpload -ne $null -and -not $storageOtherUpload.ok)
    storage_own_delete_ok = ($storageOwnDelete -ne $null -and $storageOwnDelete.ok)
  }
  debug = [ordered]@{
    anon_hash_status = $anonHash.status
    anon_hash_error = $anonHash.raw
    authed_hash_status = $authedHash.status
    authed_hash_error = $authedHash.raw
    rpc_private_status = $rpcPrivate.status
    rpc_private_error = $rpcPrivate.raw
    rpc_public_status = $rpcPublic.status
    rpc_public_error = $rpcPublic.raw
    storage_own_upload_status = if ($storageOwnUpload) { $storageOwnUpload.status } else { $null }
    storage_own_upload_error = if ($storageOwnUpload) { $storageOwnUpload.raw } else { $null }
    storage_other_upload_status = if ($storageOtherUpload) { $storageOtherUpload.status } else { $null }
    storage_other_upload_error = if ($storageOtherUpload) { $storageOtherUpload.raw } else { $null }
    storage_own_delete_status = if ($storageOwnDelete) { $storageOwnDelete.status } else { $null }
    storage_own_delete_error = if ($storageOwnDelete) { $storageOwnDelete.raw } else { $null }
  }
} | ConvertTo-Json -Depth 10
