# Skrypty — do uruchomienia na DESKTOP-KJHNO2K

Każdy skrypt sam robi punkt przywracania i **niczego nie usuwa bezpowrotnie**
poza rzeczami odtwarzalnymi (cache, pliki tymczasowe, kosz, zrzuty po BSOD).
Pliki osobiste i skróty autostartu są **przenoszone** do `D:\_Przeniesione_z_C`.

## Jak uruchomić

PowerShell **jako Administrator** (Win+X → Windows PowerShell (Administrator)):

```powershell
cd C:\Users\Pc\Downloads
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Potem po kolei, **jeden naraz**, i po każdym sprawdź, czy komputer działa:

```powershell
.\1-sprzatanie-C.ps1
```

```powershell
.\2-odinstaluj-nadmiar.ps1
```

```powershell
.\3-autostart.ps1
```

## Co robi który

| Skrypt | Co robi | Co zostaje nietknięte |
|---|---|---|
| `1-sprzatanie-C.ps1` | zwalnia ~70 GB na C:, raport o BSOD i o AppData | **wszystkie gry**, `C:\Windows\Installer`, plik wymiany |
| `2-odinstaluj-nadmiar.ps1` | usuwa SignalRGB, OpenRGB, RGB Fusion, Razer Cortex, McAfee WebAdvisor; sprawdza, czym jest `Off.exe` | NZXT CAM, iCUE, Synapse, G HUB, SteelSeries GG, AORUS LCD, Defender, zapora, Windows Update, Valorant, Vanguard, Malwarebytes |
| `3-autostart.ps1` | wyłącza 11 nadmiarowych wpisów autostartu (kopia `.reg` do cofnięcia) | SecurityHealth, RtkAudUService, NZXT CAM |

## Jak cofnąć

- pliki → przenieś z `D:\_Przeniesione_z_C` tam, skąd pochodzą (ścieżki w nazwach katalogów)
- autostart → dwuklik na `.reg` w `D:\_Przeniesione_z_C\autostart-backup`
- cała zmiana → Przywracanie systemu, punkt o nazwie z danego skryptu
