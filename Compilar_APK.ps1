$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
Write-Host '=== FotoMetrica PRO / Compilacao APK ===' -ForegroundColor Cyan
$Sdk = if ($env:ANDROID_HOME) {$env:ANDROID_HOME} elseif ($env:ANDROID_SDK_ROOT) {$env:ANDROID_SDK_ROOT} else {Join-Path $env:LOCALAPPDATA 'Android\Sdk'}
if (!(Test-Path (Join-Path $Sdk 'platforms\android-35\android.jar'))) {
  throw "Android SDK Platform 35 nao encontrado. Instale no Android Studio > Settings > Android SDK. Pasta esperada: $Sdk"
}
$studioJdk = 'C:\Program Files\Android\Android Studio\jbr'
if (Test-Path (Join-Path $studioJdk 'bin\java.exe')) {$env:JAVA_HOME=$studioJdk; $env:PATH=(Join-Path $studioJdk 'bin')+';'+$env:PATH}
if (!(Get-Command java -ErrorAction SilentlyContinue)) {throw 'Java nao encontrado. Instale Android Studio com JDK 17.'}
$gradleHome=Join-Path $Root '.buildtools\gradle-8.9'
$gradle=Join-Path $gradleHome 'bin\gradle.bat'
if (!(Test-Path $gradle)) {
  Write-Host 'Baixando Gradle 8.9 oficial (somente na primeira compilacao)...' -ForegroundColor Yellow
  $toolsDir=Join-Path $Root '.buildtools';New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
  $zip=Join-Path $toolsDir 'gradle-8.9-bin.zip'
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.9-bin.zip' -OutFile $zip -UseBasicParsing
  Expand-Archive -Path $zip -DestinationPath $toolsDir -Force
  Remove-Item $zip -Force
}
$env:ANDROID_HOME=$Sdk
& $gradle --no-daemon assembleDebug
if ($LASTEXITCODE -ne 0) {throw "Compilacao falhou, codigo $LASTEXITCODE"}
$apk=Join-Path $Root 'app\build\outputs\apk\debug\app-debug.apk'
if (!(Test-Path $apk)) {throw 'Compilacao terminou mas APK nao foi localizado.'}
$destination=Join-Path $Root 'FotoMetrica_PRO_Instalar.apk'
Copy-Item $apk $destination -Force
Write-Host "APK pronto: $destination" -ForegroundColor Green
Start-Process explorer.exe -ArgumentList ('/select,"' + $destination + '"')
