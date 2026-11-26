<#
=====================================================================
 diagnoza.ps1  -  RAPORT DIAGNOSTYCZNY PC (TYLKO DO ODCZYTU)
=====================================================================
 Cel: zebrac informacje o komputerze pod gre z PS5 przez karte
      przechwytujaca + generowanie klatek.

 WAZNE: ten skrypt NICZEGO NIE ZMIENIA w systemie.
        Wykonuje tylko odczyty (Get-*) i zapisuje jeden plik:
        raport.txt na Pulpicie.

 JAK URUCHOMIC:
   1. Kliknij prawym na Menu Start -> Windows PowerShell (administrator)
      (administrator nie jest obowiazkowy, ale bez niego czesc danych
       bedzie niedostepna: TPM, Secure Boot, SMART)
   2. Wklej i zatwierdz Enterem:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
   3. Przejdz do folderu ze skryptem, np.:
        cd $env:USERPROFILE\Desktop
   4. Uruchom:
        .\diagnoza.ps1
   5. Na Pulpicie pojawi sie raport.txt - przeslij mi jego tresc.
=====================================================================
#>

#Requires -Version 5.1

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

# ---------------------------------------------------------------- bufor
$script:Lines = New-Object System.Collections.Generic.List[string]

function W {
    param([string]$Text = '')
    $script:Lines.Add($Text) | Out-Null
    Write-Host $Text
}

function Section {
    param([string]$Title)
    W ''
    W ('=' * 70)
    W ("  " + $Title)
    W ('=' * 70)
}

function Sub {
    param([string]$Title)
    W ''
    W ("--- " + $Title + " " + ('-' * [Math]::Max(1, 60 - $Title.Length)))
}

function Try-Do {
    param([string]$What, [scriptblock]$Code)
    try   { & $Code }
    catch { W ("  [!] Nie udalo sie odczytac: $What  ($($_.Exception.Message))") }
}

function GB { param($Bytes) if ($null -eq $Bytes) { return 'brak danych' } ; '{0:N1} GB' -f ($Bytes / 1GB) }

# ---------------------------------------------------------------- start
$isAdmin = ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Section "RAPORT DIAGNOSTYCZNY - PC pod przechwytywanie PS5"
W ("Data wygenerowania : " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
W ("Komputer           : " + $env:COMPUTERNAME)
W ("Uprawnienia admina : " + $(if ($isAdmin) { 'TAK' } else { 'NIE  <-- czesc danych bedzie pominieta (TPM, Secure Boot, SMART)' }))
W ("Wersja PowerShell  : " + $PSVersionTable.PSVersion.ToString())
W ''
W 'Skrypt dziala w trybie TYLKO DO ODCZYTU - nie zmienia zadnych ustawien.'

# =====================================================================
Section "1. SYSTEM OPERACYJNY"
# =====================================================================
Try-Do 'informacje o systemie' {
    $os = Get-CimInstance Win32_OperatingSystem
    $cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
    W ("Nazwa systemu      : " + $os.Caption)
    W ("Edycja / wersja    : " + $cv.EditionID + "  /  " + $cv.DisplayVersion)
    W ("Build              : " + $cv.CurrentBuild + "." + $cv.UBR)
    W ("Architektura       : " + $os.OSArchitecture)
    W ("Zainstalowany      : " + $os.InstallDate)
    W ("Ostatni start      : " + $os.LastBootUpTime)
    W ("Uptime             : " + ((Get-Date) - $os.LastBootUpTime).ToString('d\d\ hh\:mm'))
    W ("Jezyk / locale     : " + (Get-WinSystemLocale).Name)
}

Try-Do 'poprawki Windows' {
    W ''
    W "5 ostatnich zainstalowanych aktualizacji:"
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 |
        ForEach-Object { W ("  " + $_.HotFixID + "  " + $(if ($_.InstalledOn) { $_.InstalledOn.ToString('yyyy-MM-dd') } else { '?' }) + "  " + $_.Description) }
}

# =====================================================================
Section "2. PROCESOR / PLYTA GLOWNA / BIOS"
# =====================================================================
Try-Do 'procesor' {
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    W ("Procesor           : " + $cpu.Name.Trim())
    W ("Rdzenie / watki    : " + $cpu.NumberOfCores + " / " + $cpu.NumberOfLogicalProcessors)
    W ("Baza / max (MHz)   : " + $cpu.CurrentClockSpeed + " / " + $cpu.MaxClockSpeed)
    W ("Gniazdo            : " + $cpu.SocketDesignation)
    W ("Wirtualizacja      : " + $(if ($cpu.VirtualizationFirmwareEnabled) { 'wlaczona w BIOS' } else { 'wylaczona lub brak danych' }))
}

Try-Do 'plyta glowna i BIOS' {
    W ''
    $bb   = Get-CimInstance Win32_BaseBoard
    $bios = Get-CimInstance Win32_BIOS
    $cs   = Get-CimInstance Win32_ComputerSystem
    W ("Producent plyty    : " + $bb.Manufacturer)
    W ("Model plyty        : " + $bb.Product)
    W ("Wersja plyty       : " + $bb.Version)
    W ("WERSJA BIOS        : " + $bios.SMBIOSBIOSVersion)
    W ("Data BIOS          : " + $(if ($bios.ReleaseDate) { $bios.ReleaseDate.ToString('yyyy-MM-dd') } else { '?' }))
    W ("Producent BIOS     : " + $bios.Manufacturer)
    W ("Tryb firmware      : " + $(if ($env:firmware_type) { $env:firmware_type } else { 'brak danych' }) + "   (UEFI jest wymagane do Windows 11)")
    W ("Model komputera    : " + $cs.Manufacturer + " " + $cs.Model)
}

# =====================================================================
Section "3. PAMIEC RAM  +  CZY DZIALA XMP"
# =====================================================================
Try-Do 'pamiec RAM' {
    $cs   = Get-CimInstance Win32_ComputerSystem
    $mods = Get-CimInstance Win32_PhysicalMemory
    W ("RAM lacznie        : " + (GB $cs.TotalPhysicalMemory))
    W ("Liczba kosci       : " + ($mods | Measure-Object).Count)
    W ''
    $typeMap = @{ 20 = 'DDR'; 21 = 'DDR2'; 24 = 'DDR3'; 26 = 'DDR4'; 34 = 'DDR5' }
    $maxConf = 0
    foreach ($m in $mods) {
        $t = $typeMap[[int]$m.SMBIOSMemoryType]; if (-not $t) { $t = "typ $($m.SMBIOSMemoryType)" }
        W ("  Slot " + $m.DeviceLocator + " | " + (GB $m.Capacity) + " | " + $t +
           " | zglaszana predkosc: " + $m.Speed + " MT/s" +
           " | AKTUALNIE DZIALA: " + $m.ConfiguredClockSpeed + " MT/s" +
           " | " + $m.Manufacturer + " " + $m.PartNumber)
        if ($m.ConfiguredClockSpeed -gt $maxConf) { $maxConf = [int]$m.ConfiguredClockSpeed }
    }
    W ''
    W "OCENA XMP / DOCP:"
    if ($maxConf -ge 3000) {
        W ("  OK - pamiec chodzi " + $maxConf + " MT/s, czyli profil XMP/DOCP jest najprawdopodobniej WLACZONY.")
    } elseif ($maxConf -gt 0) {
        W ("  UWAGA - pamiec chodzi tylko " + $maxConf + " MT/s.")
        W ("  Dla DDR4 wartosci 2133 / 2400 / 2666 MT/s to ustawienia domyslne (JEDEC) =")
        W ("  profil XMP/DOCP jest prawdopodobnie WYLACZONY w BIOS. Wlaczenie go daje")
        W ("  zauwazalny wzrost wydajnosci na Ryzen (Infinity Fabric).")
    } else {
        W "  Brak danych o aktualnym taktowaniu."
    }
    W "  (Wzorcowo: sprawdz tez w BIOS, ile wynosi FCLK - dla DDR4-3200 powinno byc 1600 MHz.)"
}

# =====================================================================
Section "4. KARTA GRAFICZNA I STEROWNIK NVIDIA"
# =====================================================================
Try-Do 'karty graficzne' {
    $i = 0
    foreach ($g in (Get-CimInstance Win32_VideoController)) {
        $i++
        W ("GPU #$i")
        W ("  Nazwa            : " + $g.Name)
        W ("  Wersja sterownika: " + $g.DriverVersion)
        # przeliczenie wersji sterownika NVIDIA, np. 32.0.15.7680 -> 576.80
        if ($g.Name -match 'NVIDIA|GeForce|RTX|GTX') {
            $digits = ($g.DriverVersion -replace '\.', '')
            if ($digits.Length -ge 5) {
                $last5 = $digits.Substring($digits.Length - 5)
                W ("  >> Wersja NVIDIA : " + $last5.Substring(0,3) + "." + $last5.Substring(3,2))
            }
        }
        W ("  Data sterownika  : " + $(if ($g.DriverDate) { $g.DriverDate.ToString('yyyy-MM-dd') } else { '?' }))
        W ("  Pamiec (z WMI)   : " + $(if ($g.AdapterRAM -gt 0) { GB $g.AdapterRAM } else { 'WMI nie podaje poprawnie dla >4GB' }))
        W ("  Tryb biezacy     : " + $g.CurrentHorizontalResolution + "x" + $g.CurrentVerticalResolution +
                                     " @ " + $g.CurrentRefreshRate + " Hz")
        W ("  Status           : " + $g.Status)
    }
}

Try-Do 'nvidia-smi' {
    W ''
    $smiPath = $null
    $c = Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
    if ($c) { $smiPath = $c.Source }
    if (-not $smiPath) {
        foreach ($cand in @("$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.exe",
                            "$env:SystemRoot\System32\nvidia-smi.exe")) {
            if (Test-Path $cand) { $smiPath = $cand; break }
        }
    }
    if ($smiPath) {
        W "nvidia-smi (GPU, VRAM, temperatura, limit mocy):"
        $out = & $smiPath --query-gpu=name,driver_version,vbios_version,memory.total,memory.used,temperature.gpu,power.limit,clocks.max.graphics --format=csv 2>&1
        $out | ForEach-Object { W ("  " + $_) }
    } else {
        W "nvidia-smi nie znaleziono (normalne, jesli sterownik instalowano bez narzedzi deweloperskich)."
    }
}

Sub "Ustawienia graficzne Windows wazne dla generowania klatek"
Try-Do 'HAGS / Game Mode / Game DVR' {
    $gd = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' -ErrorAction SilentlyContinue
    $hw = $gd.HwSchMode
    W ("HAGS (Harmonogram GPU z akceleracja sprzetowa) : " +
       $(switch ($hw) { 2 { 'WLACZONY (2)' } 1 { 'WYLACZONY (1)' } default { 'brak wpisu / domyslne' } }))
    $gb = Get-ItemProperty 'HKCU:\Software\Microsoft\GameBar' -ErrorAction SilentlyContinue
    W ("Tryb gry (Game Mode)                           : " +
       $(switch ($gb.AutoGameModeEnabled) { 1 { 'WLACZONY' } 0 { 'WYLACZONY' } default { 'brak wpisu / domyslne (wlaczony)' } }))
    $gc = Get-ItemProperty 'HKCU:\System\GameConfigStore' -ErrorAction SilentlyContinue
    W ("Game DVR / nagrywanie w tle                    : " +
       $(switch ($gc.GameDVR_Enabled) { 1 { 'WLACZONE' } 0 { 'WYLACZONE' } default { 'brak wpisu / domyslne' } }))
    $mpo = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' -ErrorAction SilentlyContinue
    W ("OverlayTestMode (MPO)                          : " +
       $(if ($null -ne $mpo.OverlayTestMode) { $mpo.OverlayTestMode } else { 'brak wpisu (MPO aktywne - domyslnie)' }))
}

Try-Do 'plan zasilania' {
    W ''
    $plan = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerPlan -ErrorAction SilentlyContinue |
            Where-Object { $_.IsActive }
    W ("Aktywny plan zasilania : " + $(if ($plan) { $plan.ElementName } else { 'brak danych' }))
}

# =====================================================================
Section "5. MONITORY I ODSWIEZANIE"
# =====================================================================
Try-Do 'nazwy monitorow (EDID)' {
    $ids = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue
    if ($ids) {
        foreach ($m in $ids) {
            $name = -join ($m.UserFriendlyName    | Where-Object { $_ -gt 0 } | ForEach-Object { [char]$_ })
            $man  = -join ($m.ManufacturerName    | Where-Object { $_ -gt 0 } | ForEach-Object { [char]$_ })
            $ser  = -join ($m.SerialNumberID      | Where-Object { $_ -gt 0 } | ForEach-Object { [char]$_ })
            W ("  Monitor: " + $man + " " + $name + "  (rok prod. " + $m.YearOfManufacture + ", SN " + $ser + ")")
        }
    } else { W "  Brak danych EDID z WMI." }
}

Sub "Tryby wyswietlania (aktualny i maksymalny) dla kazdego wyjscia"
Try-Do 'EnumDisplaySettings' {
$cs = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public class DispEnum {
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
    public struct DISPLAY_DEVICE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string DeviceName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceString;
        public int StateFlags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceID;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)] public string DeviceKey;
        public int cb;
    }
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
        public short dmSpecVersion, dmDriverVersion, dmSize, dmDriverExtra;
        public int dmFields;
        public int dmPositionX, dmPositionY;
        public int dmDisplayOrientation, dmDisplayFixedOutput;
        public short dmColor, dmDuplex, dmYResolution, dmTTOption, dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel, dmPelsWidth, dmPelsHeight, dmDisplayFlags, dmDisplayFrequency;
        public int dmICMMethod, dmICMIntent, dmMediaType, dmDitherType, dmReserved1, dmReserved2, dmPanningWidth, dmPanningHeight;
    }
    [DllImport("user32.dll", CharSet=CharSet.Ansi)]
    static extern bool EnumDisplayDevices(string dev, uint num, ref DISPLAY_DEVICE dd, uint flags);
    [DllImport("user32.dll", CharSet=CharSet.Ansi)]
    static extern bool EnumDisplaySettings(string devName, int modeNum, ref DEVMODE dm);

    public static List<string> Report() {
        var res = new List<string>();
        uint i = 0;
        while (true) {
            var dd = new DISPLAY_DEVICE(); dd.cb = Marshal.SizeOf(typeof(DISPLAY_DEVICE));
            if (!EnumDisplayDevices(null, i, ref dd, 0)) break;
            i++;
            if ((dd.StateFlags & 0x1) == 0) continue;            // nie podlaczony do pulpitu
            bool primary = (dd.StateFlags & 0x4) != 0;
            var cur = new DEVMODE(); cur.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
            EnumDisplaySettings(dd.DeviceName, -1, ref cur);     // -1 = ENUM_CURRENT_SETTINGS
            int bestHz = 0; int bestW = 0, bestH = 0;
            int curResBest = 0;
            var dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
            for (int m = 0; EnumDisplaySettings(dd.DeviceName, m, ref dm); m++) {
                if (dm.dmDisplayFrequency > bestHz) { bestHz = dm.dmDisplayFrequency; bestW = dm.dmPelsWidth; bestH = dm.dmPelsHeight; }
                if (dm.dmPelsWidth == cur.dmPelsWidth && dm.dmPelsHeight == cur.dmPelsHeight && dm.dmDisplayFrequency > curResBest)
                    curResBest = dm.dmDisplayFrequency;
                dm = new DEVMODE(); dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
            }
            res.Add(string.Format(
                "  {0}{1} [{2}]\n     aktualnie: {3}x{4} @ {5} Hz, {6}-bit\n     max Hz w tej rozdzielczosci: {7} Hz\n     najwyzszy tryb ogolem: {8}x{9} @ {10} Hz",
                dd.DeviceName, primary ? " (GLOWNY)" : "", dd.DeviceString,
                cur.dmPelsWidth, cur.dmPelsHeight, cur.dmDisplayFrequency, cur.dmBitsPerPel,
                curResBest, bestW, bestH, bestHz));
        }
        return res;
    }
}
'@
    if (-not ('DispEnum' -as [type])) { Add-Type -TypeDefinition $cs -ErrorAction Stop }
    $r = [DispEnum]::Report()
    if ($r.Count -eq 0) { W "  Brak aktywnych wyjsc." } else { $r | ForEach-Object { W $_ } }
    W ''
    W "  UWAGA: jesli glowny monitor nie pokazuje 240 Hz, ustaw to w"
    W "  Ustawienia > System > Ekran > Zaawansowane ustawienia ekranu."
}

Sub "HDR"
Try-Do 'HDR' {
    $hdr = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\VideoSettings' -ErrorAction SilentlyContinue
    if ($null -ne $hdr.EnableHDRForPlayback) {
        W ("  Odtwarzanie HDR/WCG (strumieniowanie wideo): " + $(if ($hdr.EnableHDRForPlayback -eq 1) { 'WLACZONE' } else { 'WYLACZONE' }))
    } else { W "  Brak wpisu o HDR dla odtwarzania." }
    W "  Stan HDR dla pulpitu sprawdz recznie: Ustawienia > System > Ekran > Windows HD Color."
}

# =====================================================================
Section "6. DYSKI, WOLNE MIEJSCE, SMART"
# =====================================================================
Try-Do 'dyski fizyczne' {
    W "Dyski fizyczne:"
    Get-Disk -ErrorAction SilentlyContinue | Sort-Object Number | ForEach-Object {
        W ("  Dysk " + $_.Number + " | " + $_.FriendlyName)
        W ("     Rozmiar: " + (GB $_.Size) + " | Tablica partycji: " + $_.PartitionStyle +
           " | Magistrala: " + $_.BusType + " | Stan: " + $_.HealthStatus + " | Rozruchowy: " + $_.IsBoot)
        if ($_.PartitionStyle -eq 'MBR' -and $_.IsBoot) {
            W "     !!! DYSK SYSTEMOWY MA MBR - do Windows 11 potrzebna konwersja na GPT (patrz BIOS_WIN11.md)"
        }
    }
}

Try-Do 'typ nosnika' {
    W ''
    W "Typ nosnika (SSD/HDD) i stan:"
    Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
        W ("  " + $_.FriendlyName + " | " + (GB $_.Size) + " | Nosnik: " + $_.MediaType +
           " | Stan: " + $_.HealthStatus + " | Zuzycie: " + $_.OperationalStatus +
           " | SpindleSpeed: " + $_.SpindleSpeed)
    }
}

Try-Do 'wolumeny' {
    W ''
    W "Wolne miejsce na dyskach:"
    Get-Volume -ErrorAction SilentlyContinue |
        Where-Object { $_.DriveLetter } | Sort-Object DriveLetter | ForEach-Object {
            $pct = if ($_.Size -gt 0) { [Math]::Round(100 * $_.SizeRemaining / $_.Size, 1) } else { 0 }
            W ("  " + $_.DriveLetter + ": " + ([string]$_.FileSystemLabel).PadRight(14) +
               " FS: " + ([string]$_.FileSystem).PadRight(6) +
               " | " + (GB $_.SizeRemaining) + " wolne z " + (GB $_.Size) + "  (" + $pct + "% wolne)")
            if ($pct -lt 10) { W "     !!! Mniej niz 10% wolnego - to psuje wydajnosc i aktualizacje." }
        }
}

Sub "SMART / licznik niezawodnosci"
if ($isAdmin) {
    Try-Do 'SMART (MSStorageDriver_FailurePredictStatus)' {
        $fp = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue
        if ($fp) {
            foreach ($d in $fp) {
                W ("  " + $d.InstanceName)
                W ("     Przewidywana awaria: " + $(if ($d.PredictFailure) { 'TAK !!! ZROB KOPIE DANYCH' } else { 'NIE (OK)' }) +
                   " | Reason: " + $d.Reason)
            }
        } else { W "  Sterownik nie udostepnia statusu SMART przez WMI." }
    }
    Try-Do 'liczniki niezawodnosci' {
        W ''
        Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
            $pd = $_
            $rc = $pd | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
            if ($rc) {
                W ("  " + $pd.FriendlyName)
                W ("     Godziny pracy: " + $rc.PowerOnHours +
                   " | Temperatura: " + $(if ($rc.Temperature) { "$($rc.Temperature) C" } else { 'brak' }) +
                   " | Max temp: " + $(if ($rc.TemperatureMax) { "$($rc.TemperatureMax) C" } else { 'brak' }))
                W ("     Bledy odczytu: " + $rc.ReadErrorsTotal + " | Bledy zapisu: " + $rc.WriteErrorsTotal +
                   " | Zuzycie: " + $(if ($null -ne $rc.Wear) { "$($rc.Wear)%" } else { 'brak (HDD)' }))
            }
        }
    }
} else {
    W "  Pominieto - wymaga uruchomienia PowerShell jako administrator."
}

# =====================================================================
Section "7. PORTY I KONTROLERY USB (wazne dla karty przechwytujacej)"
# =====================================================================
Try-Do 'kontrolery USB' {
    W "Kontrolery USB:"
    Get-CimInstance Win32_USBController -ErrorAction SilentlyContinue | ForEach-Object {
        $usb3 = $_.Name -match 'USB 3|xHCI|eXtensible'
        W ("  " + $_.Name + $(if ($usb3) { '   <-- USB 3.x (uzyj tego portu)' } else { '   (USB 2.0)' }))
    }
    W ''
    $x = Get-PnpDevice -Class USB -Status OK -ErrorAction SilentlyContinue |
         Where-Object { $_.FriendlyName -match 'xHCI|USB 3|3\.[012]|SuperSpeed' }
    if ($x) {
        W "Koncentratory / huby SuperSpeed (USB 3.x) widziane przez system:"
        $x | Select-Object -Unique FriendlyName | ForEach-Object { W ("  " + $_.FriendlyName) }
    }
    W ''
    W "WSKAZOWKA: port USB 3.x na plycie B550 jest zwykle NIEBIESKI (5 Gb/s) lub"
    W "czerwony/turkusowy (10 Gb/s). Karte przechwytujaca wtykaj BEZPOSREDNIO w plyte"
    W "glowna (tyl obudowy), nie przez hub i nie w przedni panel."
}

Try-Do 'urzadzenia obrazu / kamery' {
    W ''
    W "Urzadzenia obrazu/wideo juz podlaczone (tu pojawi sie grabber po wlozeniu):"
    $cams = Get-PnpDevice -ErrorAction SilentlyContinue |
            Where-Object { $_.Class -in @('Image','Camera','Media','AudioEndpoint') -and $_.Status -eq 'OK' -and
                           $_.FriendlyName -match 'USB|Video|Capture|HDMI|MACROSILICON|MS21' }
    if ($cams) { $cams | ForEach-Object { W ("  [" + $_.Class + "] " + $_.FriendlyName) } }
    else { W "  Nie znaleziono (grabber jeszcze niepodlaczony - to normalne)." }
}

# =====================================================================
Section "8. GOTOWOSC DO WINDOWS 11"
# =====================================================================
$script:w11 = @()

Try-Do 'TPM' {
    $tpm = $null
    try { $tpm = Get-Tpm -ErrorAction Stop } catch {}
    if ($tpm) {
        W ("TPM obecny         : " + $tpm.TpmPresent)
        W ("TPM gotowy         : " + $tpm.TpmReady)
        W ("TPM wlaczony       : " + $tpm.TpmEnabled)
    }
    $t2 = Get-CimInstance -Namespace 'root\cimv2\security\microsofttpm' -ClassName Win32_Tpm -ErrorAction SilentlyContinue
    if ($t2) {
        W ("Wersja specyfikacji: " + $t2.SpecVersion)
        W ("Producent TPM      : " + $t2.ManufacturerIdTxt)
        $ok = ($t2.SpecVersion -match '2\.0')
        $script:w11 += [pscustomobject]@{ Wymog = 'TPM 2.0'; Stan = $(if ($ok) { 'OK' } else { 'BRAK' }) }
    } else {
        W "TPM: brak danych (fTPM wylaczony w BIOS lub brak uprawnien administratora)."
        $script:w11 += [pscustomobject]@{ Wymog = 'TPM 2.0'; Stan = 'BRAK / nie wykryto - wlacz fTPM w BIOS' }
    }
}

Try-Do 'Secure Boot' {
    W ''
    $sb = $null
    try { $sb = Confirm-SecureBootUEFI -ErrorAction Stop } catch { $sb = $null }
    if ($null -ne $sb) {
        W ("Secure Boot        : " + $(if ($sb) { 'WLACZONY' } else { 'WYLACZONY (plyta w trybie UEFI - mozna wlaczyc w BIOS)' }))
        $script:w11 += [pscustomobject]@{ Wymog = 'Secure Boot'; Stan = $(if ($sb) { 'OK' } else { 'wylaczony' }) }
    } else {
        W "Secure Boot        : nie udalo sie odczytac (system w trybie Legacy/BIOS albo brak uprawnien administratora)"
        $script:w11 += [pscustomobject]@{ Wymog = 'Secure Boot'; Stan = 'nieznany' }
    }
    W ("Tryb firmware      : " + $(if ($env:firmware_type) { $env:firmware_type } else { 'brak danych' }))
}

Try-Do 'pozostale wymogi Win11' {
    W ''
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $cs  = Get-CimInstance Win32_ComputerSystem
    $sys = Get-Disk -ErrorAction SilentlyContinue | Where-Object { $_.IsBoot }
    $ramGB = [Math]::Round($cs.TotalPhysicalMemory / 1GB, 0)

    $script:w11 += [pscustomobject]@{ Wymog = 'RAM >= 4 GB';        Stan = "$ramGB GB - OK" }
    $script:w11 += [pscustomobject]@{ Wymog = 'Rdzenie >= 2';       Stan = "$($cpu.NumberOfCores) - OK" }
    $script:w11 += [pscustomobject]@{ Wymog = 'Taktowanie >= 1 GHz';Stan = "$($cpu.MaxClockSpeed) MHz - OK" }
    $script:w11 += [pscustomobject]@{ Wymog = 'Dysk systemowy GPT'; Stan = $(if ($sys) { "$($sys.PartitionStyle)" + $(if ($sys.PartitionStyle -eq 'GPT') { ' - OK' } else { ' - WYMAGA KONWERSJI (MBR2GPT)' }) } else { 'brak danych' }) }
    $script:w11 += [pscustomobject]@{ Wymog = 'Dysk systemowy >= 64 GB'; Stan = $(if ($sys) { (GB $sys.Size) } else { '?' }) }
    $script:w11 += [pscustomobject]@{ Wymog = 'Procesor na liscie Microsoft'; Stan = $cpu.Name.Trim() }

    W "PODSUMOWANIE WYMAGAN WINDOWS 11:"
    foreach ($r in $script:w11) { W ("  " + $r.Wymog.PadRight(32) + ": " + $r.Stan) }
    W ''
    W "Oficjalny test zgodnosci: aplikacja PC Health Check (Kontrola kondycji komputera) od Microsoft."
}

# =====================================================================
Section "9. AUTOSTART"
# =====================================================================
Try-Do 'autostart WMI' {
    W "Pozycje autostartu (rejestr + folder Autostart):"
    $sc = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | Sort-Object Location, Name
    if ($sc) {
        foreach ($s in $sc) {
            W ("  [" + $s.Location + "] " + $s.Name)
            W ("       " + $s.Command)
        }
        W ''
        W ("Lacznie pozycji autostartu: " + ($sc | Measure-Object).Count)
    } else { W "  Brak danych." }
}

Try-Do 'uslugi automatyczne firm trzecich' {
    W ''
    W "Uruchomione uslugi NIE-microsoftowe (kandydaci do przejrzenia):"
    $svc = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue |
           Where-Object { $_.State -eq 'Running' -and $_.StartMode -eq 'Auto' -and
                          $_.PathName -notmatch 'C:\\Windows\\' }
    if ($svc) {
        $svc | Sort-Object DisplayName | ForEach-Object { W ("  " + $_.DisplayName + "   [" + $_.Name + "]") }
        W ''
        W ("Lacznie: " + ($svc | Measure-Object).Count)
    } else { W "  Brak." }
}

Try-Do 'procesy wg pamieci' {
    W ''
    W "10 procesow zajmujacych najwiecej RAM (teraz):"
    Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 | ForEach-Object {
        W ("  " + $_.ProcessName.PadRight(28) + ('{0,8:N0} MB' -f ($_.WorkingSet64 / 1MB)))
    }
}

Sub "Oprogramowanie warte uwagi (NZXT CAM / SignalRGB / nakladki)"
Try-Do 'szukanie programow kolidujacych' {
    $keys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $apps = foreach ($k in $keys) { Get-ItemProperty $k -ErrorAction SilentlyContinue }
    $watch = 'NZXT|SignalRGB|iCUE|Corsair|Armoury|Aura|MSI (Center|Afterburner)|RGB Fusion|Razer|Logitech|Discord|Steam|OBS|Riva|Lossless|Veyra|RTSS|Fraps|Wallpaper Engine|OpenRGB'
    $hit = $apps | Where-Object { $_.DisplayName -match $watch } |
           Select-Object -Unique DisplayName, DisplayVersion | Sort-Object DisplayName
    if ($hit) { $hit | ForEach-Object { W ("  " + $_.DisplayName + "  " + $_.DisplayVersion) } }
    else { W "  Nie znaleziono." }
    W ''
    W "  UWAGA: NZXT CAM i SignalRGB (oraz inne programy RGB) czesto walcza o ten sam"
    W "  kontroler. Trzymaj TYLKO JEDEN z nich zainstalowany."
}

# =====================================================================
Section "10. TEMPERATURY (o ile system je udostepnia)"
# =====================================================================
Try-Do 'strefy termiczne ACPI' {
    $tz = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue
    if ($tz) {
        foreach ($z in $tz) {
            $c = [Math]::Round(($z.CurrentTemperature / 10) - 273.15, 1)
            W ("  " + $z.InstanceName + " : " + $c + " C")
        }
    } else {
        W "  Strefy termiczne ACPI niedostepne - to NORMALNE na wiekszosci plyt desktop."
    }
}

Try-Do 'temperatura GPU' {
    $c = Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
    if ($c) {
        $t = & $c.Source --query-gpu=temperature.gpu,utilization.gpu,power.draw --format=csv,noheader 2>&1
        W ("  GPU (nvidia-smi): " + ($t -join '; '))
    }
}

Try-Do 'LibreHardwareMonitor / OHM jesli dziala' {
    foreach ($ns in @('root\LibreHardwareMonitor','root\OpenHardwareMonitor')) {
        $s = Get-CimInstance -Namespace $ns -ClassName Sensor -ErrorAction SilentlyContinue |
             Where-Object { $_.SensorType -eq 'Temperature' }
        if ($s) {
            W ("  Z $ns :")
            $s | ForEach-Object { W ("    " + $_.Name + " : " + [Math]::Round($_.Value,1) + " C") }
        }
    }
    W ''
    W "  Jesli potrzebne dokladne temperatury CPU/VRM/SSD: uzyj HWiNFO64 (darmowe,"
    W "  oficjalna strona hwinfo.com) albo NZXT CAM, ktorego juz masz."
}

# =====================================================================
Section "11. SIEC I ZEGAR (dodatkowo)"
# =====================================================================
Try-Do 'karty sieciowe' {
    Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
        W ("  " + $_.Name + " | " + $_.InterfaceDescription + " | " + $_.LinkSpeed)
    }
}

Try-Do 'timer HPET' {
    W ''
    $bcd = & bcdedit /enum '{current}' 2>&1 | Select-String -Pattern 'useplatformclock|disabledynamictick|tscsyncpolicy'
    if ($bcd) { $bcd | ForEach-Object { W ("  bcdedit: " + $_.ToString().Trim()) } }
    else { W "  bcdedit: brak nadpisan timerow (ustawienia domyslne - tak ma byc)." }
}

# =====================================================================
Section "KONIEC RAPORTU"
# =====================================================================
W ''
W 'Co dalej:'
W '  1. Przeslij zawartosc tego pliku (raport.txt).'
W '  2. Dopiero po przeczytaniu raportu wprowadzaj zmiany z USTAWIENIA.md.'
W '  3. KAZDA zmiana w systemie = najpierw punkt przywracania.'
W ''
W ('Wygenerowano: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

# ---------------------------------------------------------------- zapis
$desktop = [Environment]::GetFolderPath('Desktop')
if (-not $desktop -or -not (Test-Path $desktop)) { $desktop = Join-Path $env:USERPROFILE 'Desktop' }
$out = Join-Path $desktop 'raport.txt'

try {
    $script:Lines -join "`r`n" | Out-File -FilePath $out -Encoding utf8 -Force
    Write-Host ''
    Write-Host ('=' * 70) -ForegroundColor Green
    Write-Host ("  ZAPISANO RAPORT: " + $out) -ForegroundColor Green
    Write-Host ('=' * 70) -ForegroundColor Green
}
catch {
    Write-Host ''
    Write-Host ("Nie udalo sie zapisac na Pulpicie: " + $_.Exception.Message) -ForegroundColor Yellow
    $alt = Join-Path $env:USERPROFILE 'raport.txt'
    $script:Lines -join "`r`n" | Out-File -FilePath $alt -Encoding utf8 -Force
    Write-Host ("Zapisano w: " + $alt) -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Nacisnij Enter, aby zamknac...'
try { Read-Host | Out-Null } catch {}
