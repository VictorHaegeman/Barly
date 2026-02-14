param(
  [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"

function Fail($message) {
  Write-Host "FAIL: $message" -ForegroundColor Red
  $script:hasFailure = $true
}

function Pass($message) {
  Write-Host "OK: $message" -ForegroundColor Green
}

$hasFailure = $false

$repoRoot = Split-Path -Parent $PSScriptRoot
$frontend = Join-Path $repoRoot "frontend"
$androidDir = Join-Path $frontend "android"
$keyPropsPath = Join-Path $androidDir "key.properties"
$localPropsPath = Join-Path $androidDir "local.properties"
$pubspecPath = Join-Path $frontend "pubspec.yaml"

Write-Host "Android release preflight - $(Get-Date -Format s)"

if (-not (Test-Path $frontend)) {
  throw "Could not locate frontend directory: $frontend"
}

if (Test-Path $keyPropsPath) {
  $keyProps = Get-Content $keyPropsPath
  foreach ($required in @("storePassword", "keyPassword", "keyAlias", "storeFile")) {
    # $keyProps is an array of lines. Use -match (not -notmatch) to avoid false positives.
    if (-not ($keyProps -match "^\s*$required\s*=\s*.+$")) {
      Fail "Missing $required in android/key.properties"
    }
  }
  Pass "android/key.properties exists and looks populated"
} else {
  Fail "Missing android/key.properties"
}

# Maps key can be provided either via local.properties (local dev) or via Gradle project property
# (CI uses ORG_GRADLE_PROJECT_MAPS_API_KEY which becomes -PMAPS_API_KEY).
$mapsKey = $null
if ($env:ORG_GRADLE_PROJECT_MAPS_API_KEY) {
  $mapsKey = $env:ORG_GRADLE_PROJECT_MAPS_API_KEY
}
elseif ($env:MAPS_API_KEY) {
  $mapsKey = $env:MAPS_API_KEY
}

if ($mapsKey -and $mapsKey.Trim().Length -gt 0) {
  Pass "MAPS_API_KEY present via environment (ORG_GRADLE_PROJECT_MAPS_API_KEY/MAPS_API_KEY)"
} elseif (Test-Path $localPropsPath) {
  $localProps = Get-Content $localPropsPath
  if ($localProps -match "^\s*MAPS_API_KEY\s*=\s*.+$") {
    Pass "MAPS_API_KEY present in android/local.properties"
  } else {
    Fail "Missing MAPS_API_KEY (set ORG_GRADLE_PROJECT_MAPS_API_KEY or add MAPS_API_KEY to android/local.properties)"
  }
} else {
  Fail "Missing MAPS_API_KEY (set ORG_GRADLE_PROJECT_MAPS_API_KEY or create android/local.properties with MAPS_API_KEY)"
}

# Try to locate a usable Java (Android Studio bundles one). If found, set JAVA_HOME for this session.
function Resolve-JavaHome {
  $candidates = @()
  if ($env:JAVA_HOME) { $candidates += $env:JAVA_HOME }
  if ($env:ProgramFiles) {
    $candidates += (Join-Path $env:ProgramFiles "Android\Android Studio\jbr")
    $candidates += (Join-Path $env:ProgramFiles "Android\Android Studio\jre")
    $candidates += (Join-Path $env:ProgramFiles "Java\jdk-21")
    $candidates += (Join-Path $env:ProgramFiles "Java\jdk-17")
  }
  # Don't use $home as a loop variable: $HOME is a built-in read-only variable.
  foreach ($candidateHome in $candidates) {
    if ($candidateHome -and (Test-Path (Join-Path $candidateHome "bin\java.exe"))) {
      return $candidateHome
    }
  }
  return $null
}

$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCmd) {
  $resolvedHome = Resolve-JavaHome
  if ($resolvedHome) {
    $env:JAVA_HOME = $resolvedHome
    $env:PATH = (Join-Path $resolvedHome "bin") + ";" + $env:PATH
    $javaCmd = Get-Command java -ErrorAction SilentlyContinue
  }
}

if ($javaCmd) {
  # `java -version` writes to stderr; in PowerShell this can be treated as an error when
  # $ErrorActionPreference = "Stop". Use cmd.exe to capture output safely.
  $javaVersion = (cmd /c "java -version 2>&1")
  if ($VerboseOutput) { $javaVersion | ForEach-Object { Write-Host $_ } }
  Pass "java command available"
} else {
  Fail "java not found (install a JDK or set JAVA_HOME, e.g. to Android Studio's jbr)"
}

if ($env:JAVA_HOME) {
  Pass "JAVA_HOME is set"
} else {
  Fail "JAVA_HOME is not set"
}

if (Get-Command flutter -ErrorAction SilentlyContinue) {
  Pass "flutter command available"
} else {
  Fail "flutter not found in PATH"
}

if (Test-Path $pubspecPath) {
  $pubspec = Get-Content $pubspecPath
  $versionLine = $pubspec | Where-Object { $_ -match "^\s*version:\s*" } | Select-Object -First 1
  if ($null -ne $versionLine) {
    Pass "pubspec version found: $($versionLine.Trim())"
  } else {
    Fail "No version found in pubspec.yaml"
  }
}

if ($hasFailure) {
  Write-Host ""
  Write-Host "Android release preflight: FAILED" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Android release preflight: PASSED" -ForegroundColor Green
exit 0
