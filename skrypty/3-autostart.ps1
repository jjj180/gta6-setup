<#
  3-autostart.ps1
  Wylacza nadmiarowe programy z autostartu. W 100% ODWRACALNE:
   - klucze rejestru Run sa najpierw eksportowane do D:\_Przeniesione_z_C\autostart-backup\*.reg
   - skroty z folderow Autostart sa PRZENOSZONE (nie usuwane) do tego samego katalogu
  Zeby cofnac: kliknij dwukrotnie pliki .reg i wrzuc skroty z powrotem.
  ZOSTAWIA: SecurityHealth (Defender), RtkAudUService (dzwiek), NZXT CAM (chlodzenie).
  Uruchom JAKO ADMINISTRATOR.
#>

$ErrorActionPreference = 'Continue'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "STOP: uruchom jako Administrator." -ForegroundColor Red; return
}
function Krok($t){ Write-Host "`n>>> $t" -ForegroundColor Cyan }

$kopia = 'D:\_Przeniesione_z_C\autostart-backup'
New-Item -ItemType Directory -Force -Path $kopia | Out-Null

Krok "Punkt przywracania"
Enable-ComputerRestore -Drive "C:\"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' `
  -Name 'SystemRestorePointCreationFrequency' -Value 0 -PropertyType DWord -Force | Out-Null
Checkpoint-Computer -Description "przed zmiana autostartu" -RestorePointType MODIFY_SETTINGS
Write-Host "   OK" -ForegroundColor Green

Krok "Kopia zapasowa kluczy autostartu do $kopia"
$klucze = @{
  'HKCU-Run'       = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
  'HKLM-Run'       = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
  'HKLM-Run-32bit' = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
}
foreach ($k in $klucze.GetEnumerator()) {
  reg export $k.Value "$kopia\$($k.Key).reg" /y | Out-Null
  Write-Host "   $($k.Key).reg" -ForegroundColor Green
}

Krok "Co jest teraz w autostarcie (przed zmiana)"
Get-CimInstance Win32_StartupCommand |
  Select-Object Name, Location, @{n='Komenda';e={ $_.Command.Substring(0,[Math]::Min(70,$_.Command.Length)) }} |
  Format-Table -AutoSize

# --- wpisy do wylaczenia ---------------------------------------------------
# dopasowanie po fragmencie nazwy wpisu LUB sciezki w komendzie
$wylacz = @(
  'OneDrive', 'Teams', 'Opera', 'GoogleChromeAutoLaunch', 'MicrosoftEdgeAutoLaunch',
  'GoogleUpdater', 'Roblox', 'PDFgear', 'Epson', 'Elgato', 'CyberGhost'
)
# te zostawiamy mimo dopasowania - bezpiecznik
$zostaw = @('SecurityHealth', 'RtkAudUService', 'NZXT CAM', 'NZXT')

Krok "Wylaczam wpisy rejestru Run"
$runPS = @(
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
)
$zmienione = 0
foreach ($r in $runPS) {
  if (-not (Test-Path $r)) { continue }
  $wpisy = Get-Item $r
  foreach ($nazwa in $wpisy.GetValueNames()) {
    $wartosc = $wpisy.GetValue($nazwa)
    if ($zostaw | Where-Object { $nazwa -like "*$_*" -or $wartosc -like "*$_*" }) {
      Write-Host "   ZOSTAWIAM: $nazwa" -ForegroundColor DarkGray; continue
    }
    if ($wylacz | Where-Object { $nazwa -like "*$_*" -or $wartosc -like "*$_*" }) {
      Remove-ItemProperty -Path $r -Name $nazwa -Force
      Write-Host "   wylaczone: $nazwa" -ForegroundColor Yellow
      $zmienione++
    }
  }
}

Krok "Przenosze skroty z folderow Autostart (nie usuwam)"
@(
  "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
  "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
) | ForEach-Object {
  if (-not (Test-Path $_)) { return }
  Get-ChildItem $_ -File -Force | ForEach-Object {
    $f = $_
    if ($zostaw | Where-Object { $f.Name -like "*$_*" }) {
      Write-Host "   ZOSTAWIAM: $($f.Name)" -ForegroundColor DarkGray; return
    }
    if ($f.Name -like '*Off*') {
      Write-Host "   ZOSTAWIAM na razie: $($f.Name) - najpierw ustalamy, co to jest" -ForegroundColor Magenta; return
    }
    if ($wylacz | Where-Object { $f.Name -like "*$_*" }) {
      Move-Item $f.FullName $kopia -Force
      Write-Host "   przeniesione: $($f.Name)" -ForegroundColor Yellow
      $zmienione++
    }
  }
}

Krok "Autostart PO zmianie"
Get-CimInstance Win32_StartupCommand | Select-Object Name, Location | Format-Table -AutoSize

Krok "WYNIK"
Write-Host "Wylaczonych pozycji: $zmienione" -ForegroundColor Green
Write-Host "Kopia do cofniecia: $kopia" -ForegroundColor Green
Write-Host "Zmiany dzialaja po ponownym uruchomieniu komputera." -ForegroundColor Yellow
Write-Host "`nUWAGA: OneDrive i Teams nadal sa zainstalowane - tylko nie startuja same." -ForegroundColor DarkGray
