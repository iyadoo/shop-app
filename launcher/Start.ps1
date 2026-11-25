param([switch]$Direct, [switch]$ServerOnly, [string]$Mode = '')
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Base = Split-Path -Parent $Root
$url = 'http://127.0.0.1:8765'
$appUrl = $url + '/'
if ($Mode -eq 'pos') { $appUrl = $url + '/?m=pos' } elseif ($Mode -eq 'acc') { $appUrl = $url + '/?m=acc' }
function Up { try { return ((Invoke-WebRequest ($url + '/api/ping') -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200) } catch { return $false } }
if (-not (Up)) {
    Start-Process powershell -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + $Root + '\Server.ps1"'))
    for ($i = 0; $i -lt 60; $i++) { if (Up) { break }; Start-Sleep -Milliseconds 500 }
}
if ($ServerOnly) { exit }
# desktop shortcuts: POS + ACC
try {
    $desk = [Environment]::GetFolderPath('Desktop')
    $ws = New-Object -ComObject WScript.Shell
    foreach ($m in @('POS', 'ACC')) {
        $lnk = Join-Path $desk ($m + '.lnk')
        if (-not (Test-Path $lnk)) {
            $s = $ws.CreateShortcut($lnk)
            $s.TargetPath = "$env:WINDIR\System32\wscript.exe"
            $s.Arguments = '"' + (Join-Path $Root 'Launch.vbs') + '" ' + $m.ToLower()
            $s.WorkingDirectory = $Root
            $ico = Join-Path $Root 'PosByIyad.ico'
            if (Test-Path $ico) { $s.IconLocation = $ico }
            $s.Description = 'GRAND ' + $m
            $s.Save()
        }
    }
} catch {}

$cands = @(
    "$env:ProgramFiles (x86)\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$cands[0] = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$exe = $null
foreach ($c in $cands) { if (Test-Path $c) { $exe = $c; break } }
if ($exe) {
    $prof = Join-Path $Base 'Profile'
    $a = @("--app=$appUrl", '--start-maximized', '--no-first-run', "--user-data-dir=`"$prof`"")
    if ($Direct) { $a += '--kiosk-printing' }
    Start-Process $exe -ArgumentList $a
} else {
    Start-Process $appUrl
}
