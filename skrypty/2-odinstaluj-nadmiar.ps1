<#
  2-odinstaluj-nadmiar.ps1
  Usuwa nadmiarowe programy, ktore realnie przeszkadzaja:
  4 programy do RGB naraz (konflikt o kontroler Krakena), "game booster" i bloatware.
  ZOSTAWIA: NZXT CAM, Corsair iCUE, Razer Synapse, Logitech G HUB, SteelSeries GG,
            AORUS LCD Panel Service, Defender, zapore, Windows Update.
  NIE dotyka: Valoranta ani Riot Vanguard - uzytkownik je zachowuje.
  Uruchom JAKO ADMINISTRATOR.
#>

$ErrorActionPreference = 'Continue'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "STOP: uruchom jako Administrator." -ForegroundColor Red; return
}

function Krok($t){ Write-Host "`n>>> $t" -ForegroundColor Cyan }

Krok "Punkt przywracania"
Enable-ComputerRestore -Drive "C:\"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' `
  -Name 'SystemRestorePointCreationFrequency' -Value 0 -PropertyType DWord -Force | Out-Null
Checkpoint-Computer -Description "przed odinstalowaniem nadmiaru" -RestorePointType APPLICATION_UNINSTALL
if (-not (Get-ComputerRestorePoint)) { Write-Host "   UWAGA: brak punktu przywracania. Przerywam." -ForegroundColor Red; return }
Write-Host "   OK" -ForegroundColor Green

# --- co usuwamy -------------------------------------------------------------
$doUsuniecia = @(
  @{ Nazwa='SignalRGB';        Powod='konflikt z NZXT CAM o kontroler Krakena' },
  @{ Nazwa='OpenRGB';          Powod='trzeci program do tego samego' },
  @{ Nazwa='RGB Fusion';       Powod='czwarty program do tego samego' },
  @{ Nazwa='Razer Cortex';     Powod='"game booster" - nic nie przyspiesza, dodaje narzut' },
  @{ Nazwa='WebAdvisor';       Powod='bloatware McAfee' },
  @{ Nazwa='Malwarebytes';     Powod='drugi skaner w czasie rzeczywistym obok Defendera - zrodlo przycinek' }
)

$kluczeUninstall = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
function Lista {
  $kluczeUninstall | ForEach-Object {
    Get-ItemProperty $_ -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
  }
}
$zainstalowane = Lista

$doRecznie = @()

foreach ($cel in $doUsuniecia) {
  Krok "$($cel.Nazwa)  -  $($cel.Powod)"
  $trafienia = $zainstalowane | Where-Object { $_.DisplayName -like "*$($cel.Nazwa)*" }
  if (-not $trafienia) { Write-Host "   nie ma go w systemie - pomijam" -ForegroundColor DarkGray; continue }

  foreach ($t in $trafienia) {
    Write-Host "   znalezione: $($t.DisplayName) $($t.DisplayVersion)" -ForegroundColor Yellow
    $zrobione = $false

    # 1) winget - najcichsza i najpewniejsza droga
    if (Get-Command winget -ErrorAction SilentlyContinue) {
      winget uninstall --name "$($t.DisplayName)" --silent --accept-source-agreements `
        --disable-interactivity 2>&1 | Out-Null
      if ($LASTEXITCODE -eq 0) { Write-Host "   OK (winget)" -ForegroundColor Green; $zrobione = $true }
    }

    # 2) MSI - cichy deinstalator
    if (-not $zrobione -and $t.PSChildName -match '^\{[0-9A-Fa-f\-]+\}$') {
      $r = Start-Process msiexec.exe -ArgumentList "/x $($t.PSChildName) /qn /norestart" -Wait -PassThru
      if ($r.ExitCode -in 0,1605,3010) { Write-Host "   OK (msiexec)" -ForegroundColor Green; $zrobione = $true }
    }

    # 3) wlasny deinstalator z przelacznikiem cichym
    if (-not $zrobione -and $t.UninstallString) {
      $us  = $t.UninstallString.Trim()
      $exe = $null; $arg = ''
      if     ($us -match '^"([^"]+)"\s*(.*)$') { $exe = $Matches[1]; $arg = $Matches[2] }
      elseif ($us -match '^(.+?\.exe)\s*(.*)$') { $exe = $Matches[1]; $arg = $Matches[2] }
      if ($exe -and (Test-Path $exe)) {
        foreach ($cichy in '/S','/silent','--silent','/VERYSILENT /SUPPRESSMSGBOXES /NORESTART') {
          Start-Process $exe -ArgumentList ("$arg $cichy").Trim() -Wait -ErrorAction SilentlyContinue
          Start-Sleep 3
          if (-not (Lista | Where-Object { $_.DisplayName -eq $t.DisplayName })) {
            Write-Host "   OK (deinstalator $cichy)" -ForegroundColor Green; $zrobione = $true; break
          }
        }
      }
    }

    if (-not $zrobione) {
      Write-Host "   NIE DA SIE CICHO - zrob recznie" -ForegroundColor Red
      $doRecznie += $t.DisplayName
    }
  }
}

# --- resztki SignalRGB ------------------------------------------------------
Krok "Resztki SignalRGB (silnik VortxEngine) - tylko jesli program juz odinstalowany"
if (-not (Lista | Where-Object { $_.DisplayName -like '*SignalRGB*' })) {
  if (Test-Path "$env:LOCALAPPDATA\VortxEngine") {
    Write-Host "   przenosze do D:\_Przeniesione_z_C\VortxEngine (nie usuwam)" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path 'D:\_Przeniesione_z_C' | Out-Null
    robocopy "$env:LOCALAPPDATA\VortxEngine" 'D:\_Przeniesione_z_C\VortxEngine' /MOVE /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
  } else { Write-Host "   nie ma resztek" -ForegroundColor DarkGray }
}

# --- raport ----------------------------------------------------------------
Krok "WYNIK"
if ($doRecznie) {
  Write-Host "Do usuniecia recznie (Ustawienia > Aplikacje > Aplikacje i funkcje):" -ForegroundColor Yellow
  $doRecznie | ForEach-Object { Write-Host "   - $_" }
  Write-Host "Otwieram Ustawienia..." -ForegroundColor DarkGray
  Start-Process 'ms-settings:appsfeatures'
} else {
  Write-Host "Wszystko odinstalowane cicho. Nic do klikania." -ForegroundColor Green
}

Krok "Co to jest Off.exe z autostartu (tylko sprawdzam, nic nie zmieniam)"
$off = 'C:\Program Files (x86)\Off\Off.exe'
if (Test-Path $off) {
  Get-Item $off | Select-Object FullName, Length, CreationTime, LastWriteTime | Format-List
  (Get-Item $off).VersionInfo | Select-Object CompanyName, ProductName, FileDescription, FileVersion | Format-List
  Get-AuthenticodeSignature $off | Select-Object Status, @{n='Podpisal';e={$_.SignerCertificate.Subject}} | Format-List
  "SHA256: " + (Get-FileHash $off -Algorithm SHA256).Hash
  Write-Host "Wklej mi te dane - ocenie, czy to zostawic. NIE usuwam tego sam." -ForegroundColor Yellow
} else { Write-Host "   nie ma takiego pliku" -ForegroundColor DarkGray }

Write-Host "`nNIE ruszalem: Valoranta, Riot Vanguard, Defendera, zapory, Windows Update." -ForegroundColor Green
