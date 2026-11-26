# GTA 6 z PS5 na PC — karta przechwytująca + generowanie klatek

Zestaw: **PS5 (GTA 6, 30 FPS) → grabber HDMI USB 3.0 → PC (Ryzen 7 5700X, RTX 3070 Ti 8 GB, 32 GB) → MSI MAG 271QP QD-OLED 1440p 240 Hz**
Cel: **60–120 FPS na ekranie, priorytet małe opóźnienie.**

## Pliki

| Plik | Co to jest |
|---|---|
| **`diagnoza.ps1`** | Skrypt PowerShell **tylko do odczytu** — nic nie zmienia. Zbiera dane o sprzęcie i zapisuje `raport.txt` na Pulpicie. **Uruchom to pierwsze.** |
| **`USTAWIENIA.md`** | Instrukcja krok po kroku: PS5, kable, program do generowania klatek, Windows, NVIDIA, czyszczenie systemu |
| **`BIOS_WIN11.md`** | Włączenie fTPM i Secure Boot na Gigabyte B550 Gaming X V2 + darmowa aktualizacja do Windows 11 (z ostrzeżeniem MBR→GPT) |

## Kolejność działania

1. **`diagnoza.ps1`** → prześlij mi `raport.txt`
2. **`BIOS_WIN11.md`** → fTPM, Secure Boot, Windows 11
3. **Kup grabber** (patrz niżej)
4. **`USTAWIENIA.md`** → konfiguracja wszystkiego

## Jak uruchomić diagnozę

1. Pobierz `diagnoza.ps1` na Pulpit
2. Start → prawy klik → **Windows PowerShell (administrator)**
3. Wklej:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
   cd $env:USERPROFILE\Desktop
   .\diagnoza.ps1
   ```
4. Na Pulpicie pojawi się **`raport.txt`**

Skrypt wykonuje wyłącznie odczyty (`Get-*`, zapytania CIM/WMI). Nie zmienia ustawień, rejestru ani plików systemowych — jedyne, co zapisuje, to `raport.txt`.

## Co kupić

**Grabber HDMI USB 3.0 na układzie MacroSilicon MS2131, ~50–70 zł.**

Na co patrzeć w ofercie:
- ✅ w opisie wprost **MS2131** (albo MS2130) i **USB 3.0**
- ✅ „1080p 60 fps”, format **YUY2 / NV12**
- ❌ **nie MS2109** — to układ USB 2.0, da maksymalnie 1080p**30** w MJPEG
- ❌ nie bierz niczego za 20–30 zł z napisem „4K” — to zwykle MS2109 w przebraniu
- „4K” w tytule oznacza tylko maksymalne **wejście** / pętlę HDMI; **przechwytywanie to zawsze 1080p60**

Szczegółowe kryteria zakupu i uzasadnienie — w `USTAWIENIA.md`.

## Jaki program

**Veyra NR** (darmowa, GPL-3.0) — https://github.com/Likely7/Veyra-NRVideo/releases/latest
Wymaga **Windows 11** → dlatego najpierw `BIOS_WIN11.md`.

Alternatywa na Windows 10: **Lossless Scaling**, 27 zł na Steamie — https://store.steampowered.com/app/993090/

Porównanie i uzasadnienie wyboru — w `USTAWIENIA.md`, rozdziały 4 i 5.

## Zasady bezpieczeństwa (obowiązują w całym zestawie)

- Każda zmiana w systemie zaczyna się od **punktu przywracania**
- **Nie wyłączamy** Defendera, zapory ani Windows Update
- **Nie dodajemy** wyjątków w Defenderze dla instalatorów — zamiast tego sprawdzamy sumę **SHA256**
- Tylko **oficjalne źródła**. Żadnych paczek „GTA 6 PC”, „PS5 60FPS Patch” ani „boosterów”
