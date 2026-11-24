# Create Android release keystore (run once). Requires keytool (JDK / Android Studio JBR).
#
# Usage (path with spaces):
#   & "D:\path\to\android\create_release_keystore.ps1"
#
# After success you should have:
#   - android/app/upload-keystore.jks
#   - android/key.properties   (gitignored — back it up outside the repo)
#
# Then build AAB for Play Console:
#   cd <flutter_project_root>
#   flutter build appbundle --release
#
# Tip: use ASCII letters/numbers in passwords to avoid rare Gradle .properties encoding issues.

$ErrorActionPreference = "Stop"
$androidDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$appDir = Join-Path $androidDir "app"
$jks = Join-Path $appDir "upload-keystore.jks"

$keytool = @(
    "${env:ProgramFiles}\Android\Android Studio\jbr\bin\keytool.exe"
    "${env:ProgramFiles(x86)}\Android\Android Studio\jbr\bin\keytool.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $keytool) {
    Write-Host "keytool not found. Add JDK to PATH or edit paths in this script."
    exit 1
}

if (Test-Path $jks) {
    Write-Host "File already exists: $jks"
    Write-Host "Delete it first if you want a new keystore."
    exit 1
}

$storePass = Read-Host "Keystore password (used for storePassword and keyPassword)"
if ([string]::IsNullOrWhiteSpace($storePass)) {
    Write-Host "Cancelled."
    exit 1
}

# Use double-quoted string so special apostrophes cannot break parsing.
$dname = "CN=Waslny Users, OU=Mobile, O=Waslny, L=Kafr El Sheikh, ST=KS, C=EG"

& $keytool -genkeypair -v `
    -storetype PKCS12 `
    -keystore $jks `
    -alias upload `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -storepass $storePass -keypass $storePass `
    -dname $dname

if ($LASTEXITCODE -ne 0) {
    Write-Host "keytool failed (exit code $LASTEXITCODE). Keystore was not created."
    exit 1
}

if (-not (Test-Path $jks)) {
    Write-Host "keytool reported success but file is missing: $jks"
    exit 1
}

$props = @(
    "storePassword=$storePass"
    "keyPassword=$storePass"
    "keyAlias=upload"
    "storeFile=upload-keystore.jks"
) -join "`n"

$propsPath = Join-Path $androidDir "key.properties"
Set-Content -Path $propsPath -Value $props -Encoding utf8
Write-Host ""
Write-Host "Created: $jks"
Write-Host "Created: $propsPath"
Write-Host "Back up both files outside the project (they are gitignored)."
