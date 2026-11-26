<#
  1-sprzatanie-C.ps1
  Zwalnia miejsce na C: BEZ RUSZANIA GIER.
  Pliki osobiste sa PRZENOSZONE do D:\_Przeniesione_z_C (nic nie ginie).
  Usuwane jest tylko to, co jednoznacznie odtwarzalne: zrzuty po BSOD, cache shaderow,
  pliki tymczasowe, kosz, cache aktualizacji.
  Uruchom w PowerShellu JAKO ADMINISTRATOR.
#>

$ErrorActionPreference = 'SilentlyContinue'

# --- warunki wstepne -------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "STOP: uruchom ten skrypt jako Administrator." -ForegroundColor Red; return
}
if (-not (Test-Path 'D:\')) {
  Write-Host "STOP: nie widze dysku D:. Przerywam, zeby nic nie przenosic w zle miejsce." -ForegroundColor Red; return
}

$log = "D:\_Przeniesione_z_C\log-sprzatanie-$(Get-Date -f yyyyMMdd-HHmm).txt"
New-Item -ItemType Directory -Force -Path 'D:\_Przeniesione_z_C','D:\_Przeniesione_z_C\Downloads' | Out-Null
Start-Transcript -Path $log -Force | Out-Null

$before = (Get-Volume -DriveLetter C).SizeRemaining

function Krok($t){ Write-Host "`n>>> $t" -ForegroundColor Cyan }
function Rozmiar($p){
  if (Test-Path $p) { "{0:N1}" -f (((Get-ChildItem $p -Recurse -File -Force | Measure-Object Length -Sum).Sum)/1GB) } else { "0" }
}
function Przenies($z,$c){
  if (-not (Test-Path $z)) { Write-Host "   pomijam (nie ma): $z" -ForegroundColor DarkGray; return }
  Write-Host "   $(Rozmiar $z) GB : $z" -ForegroundColor Yellow
  robocopy "$z" "$c" /MOVE /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -lt 8) { Write-Host "   OK" -ForegroundColor Green }
  else { Write-Host "   BLAD $LASTEXITCODE - nic nie usunieto, pliki zostaly na C:" -ForegroundColor Red }
}

# --- 1. punkt przywracania -------------------------------------------------
Krok "Punkt przywracania (zelazna zasada: kazdy blok zmian zaczyna sie od tego)"
Enable-ComputerRestore -Drive "C:\"
# Windows blokuje kolejny punkt czesciej niz raz na 24 h - zdejmujemy limit na ten jeden raz
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' `
  -Name 'SystemRestorePointCreationFrequency' -Value 0 -PropertyType DWord -Force | Out-Null
Checkpoint-Computer -Description "przed sprzataniem C" -RestorePointType MODIFY_SETTINGS
$p = Get-ComputerRestorePoint | Sort-Object CreationTime | Select-Object -Last 1
if ($p) { Write-Host "   utworzony: $($p.Description) $($p.CreationTime)" -ForegroundColor Green }
else    { Write-Host "   UWAGA: nie udalo sie utworzyc punktu. Przerywam." -ForegroundColor Red; Stop-Transcript | Out-Null; return }

# --- 2. przenoszenie plikow osobistych ------------------------------------
Krok "PRZENOSZE duze pliki osobiste na D: (GRY ZOSTAJA NA C:)"
Przenies 'C:\Users\Pc\Videos\Desktop'                                 'D:\_Przeniesione_z_C\Nagrania_Desktop'
Przenies 'C:\Users\Pc\Desktop\Sons Of The Forest Build.24022023'      'D:\_Przeniesione_z_C\Sons Of The Forest Build'
Przenies 'C:\Users\Pc\Desktop\_Logi_Inne'                             'D:\_Przeniesione_z_C\_Logi_Inne'

Write-Host "   Pliki >200 MB z Downloads:" -ForegroundColor Yellow
Get-ChildItem 'C:\Users\Pc\Downloads' -Recurse -File -Force |
  Where-Object { $_.Length -gt 200MB } | ForEach-Object {
    Write-Host ("      {0:N1} GB  {1}" -f ($_.Length/1GB), $_.Name)
    Move-Item $_.FullName 'D:\_Przeniesione_z_C\Downloads\' -Force
  }

# --- 3. usuwanie rzeczy odtwarzalnych -------------------------------------
Krok "USUWAM zrzut pamieci po niebieskim ekranie (raport o BSOD jest nizej)"
if (Test-Path 'C:\Windows\MEMORY.DMP') { Write-Host "   $(Rozmiar 'C:\Windows\MEMORY.DMP') GB : MEMORY.DMP" -ForegroundColor Yellow }
Remove-Item 'C:\Windows\MEMORY.DMP' -Force
Remove-Item 'C:\Windows\Minidump\*' -Recurse -Force

Krok "USUWAM stare paczki sterownikow NVIDII i cache shaderow (odtworzy sie same)"
@(
  'C:\ProgramData\NVIDIA Corporation\Downloader',
  'C:\ProgramData\NVIDIA Corporation\NV_Cache',
  'C:\ProgramData\NVIDIA\DXCache',
  'C:\ProgramData\NVIDIA\GLCache',
  "$env:LOCALAPPDATA\NVIDIA\DXCache",
  "$env:LOCALAPPDATA\NVIDIA\GLCache",
  "$env:LOCALAPPDATA\D3DSCache"
) | ForEach-Object { Remove-Item "$_\*" -Recurse -Force }

Krok "USUWAM pliki tymczasowe, kosz i cache aktualizacji"
Remove-Item 'C:\Windows\Temp\*' -Recurse -Force
Remove-Item "$env:TEMP\*" -Recurse -Force
Clear-RecycleBin -Force -Confirm:$false
try { Delete-DeliveryOptimizationCache -Force } catch { Write-Host "   (cache Delivery Optimization pominiety)" -ForegroundColor DarkGray }

# --- 4. raporty ------------------------------------------------------------
Krok "RAPORT: co jeszcze zajmuje miejsce w AppData\Local"
Get-ChildItem "$env:LOCALAPPDATA" -Directory -Force | ForEach-Object {
  [pscustomobject]@{
    GB     = [math]::Round(((Get-ChildItem $_.FullName -Recurse -File -Force | Measure-Object Length -Sum).Sum)/1GB,1)
    Folder = $_.Name }
} | Sort-Object GB -Descending | Select-Object -First 12 | Format-Table -AutoSize

Krok "RAPORT: niebieskie ekrany / twarde wylaczenia (ID 41, 1001, 6008)"
Get-WinEvent -FilterHashtable @{LogName='System'; Id=41,1001,6008} -MaxEvents 8 |
  Select-Object TimeCreated, Id, ProviderName | Format-Table -AutoSize
Write-Host "   Szczegoly ostatniego BSOD (jesli byl):" -ForegroundColor DarkGray
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001} -MaxEvents 2 |
  ForEach-Object { $_.TimeCreated; ($_.Message -split "`n")[0..3] -join ' ' }

# --- 5. wynik --------------------------------------------------------------
Krok "WYNIK"
$v = Get-Volume -DriveLetter C
"Przed   : {0:N1} GB wolne" -f ($before/1GB)
"Teraz   : {0:N1} GB wolne  ({1:N1}%)" -f ($v.SizeRemaining/1GB), (100*$v.SizeRemaining/$v.Size)
"Zyskane : {0:N1} GB" -f (($v.SizeRemaining - $before)/1GB)
Write-Host "`nPrzeniesione pliki: D:\_Przeniesione_z_C   (log: $log)" -ForegroundColor Green
Write-Host "Nic nie zostalo bezpowrotnie usuniete poza zrzutami BSOD, cache i koszem." -ForegroundColor Green

Stop-Transcript | Out-Null
