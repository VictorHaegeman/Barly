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
    if ($keyProps -notmatch "^\s*$required\s*=\s*.+$") {
      Fail "Missing $required in android/key.properties"
    }
  }
  Pass "android/key.properties exists and looks populated"
} else {
  Fail "Missing android/key.properties"
}

if (Test-Path $localPropsPath) {
  $localProps = Get-Content $localPropsPath
  if ($localProps -match "^\s*MAPS_API_KEY\s*=\s*.+$") {
    Pass "MAPS_API_KEY present in android/local.properties"
  } else {
    Fail "Missing MAPS_API_KEY in android/local.properties"
  }
} else {
  Fail "Missing android/local.properties"
}

if (Get-Command java -ErrorAction SilentlyContinue) {
  $javaVersion = (& java -version) 2>&1
  if ($VerboseOutput) {
    $javaVersion | ForEach-Object { Write-Host $_ }
  }
  Pass "java command available"
} else {
  Fail "java not found in PATH"
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
