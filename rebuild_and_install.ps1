$root = 'C:\Users\靖喻\elderly_medication_app'
$apk = Join-Path $root 'build\app\outputs\flutter-apk\app-debug.apk'
$adb = 'C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe'

$env:PUB_CACHE = 'C:\Users\靖喻\elderly_medication_app\.pub-cache'
$env:GRADLE_OPTS = '-Dorg.gradle.daemon=false -Dkotlin.compiler.execution.strategy=in-process -Dkotlin.incremental=false'

Set-Location $root
& 'C:\flutter_sdk\bin\flutter.bat' build apk --debug
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& $adb -s emulator-5554 install -r $apk
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& $adb -s emulator-5554 shell am start -n com.example.elderly_medication_app/com.example.elderly_medication_app.MainActivity
