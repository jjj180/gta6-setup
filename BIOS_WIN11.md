# BIOS_WIN11.md — fTPM + Secure Boot na Gigabyte B550 Gaming X V2 i darmowa aktualizacja do Windows 11

Dla: **Gigabyte B550 Gaming X V2 + Ryzen 7 5700X + Windows 10**
Cel: spełnić wymagania Windows 11 i zaktualizować system **bezpłatnie**, bez utraty plików i programów.

Dlaczego to robisz: **Veyra NR wymaga Windows 11 x64 i DirectX 12** — to warunek konieczny, nie zalecenie. Dodatkowo Lossless Scaling podaje Windows 11 24H2 jako konfigurację *zalecaną*.

---

## Spis treści

1. [Czy to w ogóle warto? Krótka odpowiedź](#1-czy-to-w-ogóle-warto)
2. [KROK 0 — zabezpiecz się (NIE POMIJAJ)](#krok-0--zabezpiecz-się-nie-pomijaj)
3. [KROK 1 — sprawdź, co masz](#krok-1--sprawdź-co-masz)
4. [KROK 2 — MBR → GPT (jeśli trzeba)](#krok-2--mbr--gpt-jeśli-trzeba)
5. [KROK 3 — aktualizacja BIOS-u (zalecana przed fTPM)](#krok-3--aktualizacja-biosu-zalecana-przed-ftpm)
6. [KROK 4 — włącz fTPM w BIOS](#krok-4--włącz-ftpm-w-bios)
7. [KROK 5 — włącz Secure Boot w BIOS](#krok-5--włącz-secure-boot-w-bios)
8. [KROK 6 — sprawdź w Windowsie](#krok-6--sprawdź-w-windowsie)
9. [KROK 7 — aktualizacja do Windows 11](#krok-7--aktualizacja-do-windows-11)
10. [KROK 8 — po aktualizacji](#krok-8--po-aktualizacji)
11. [Ratunek — co robić, gdy komputer nie startuje](#ratunek)

---

## 1. Czy to w ogóle warto?

**Tak.** Trzy powody:

1. **Veyra NR nie uruchomi się na Windows 10.** Wymaga Windows 11 x64 + DirectX 12. Bez tego zostaje ci tylko Lossless Scaling, który nie ma usuwania zdublowanych klatek — a to kluczowa funkcja dla gry 30 FPS z PS5.
2. **Aktualizacja jest darmowa.** Twoja licencja Windows 10 przechodzi na Windows 11 automatycznie, bez dopłaty i bez wpisywania klucza.
3. **Windows 10 jest już po oficjalnym końcu wsparcia** (14 października 2025). Działa dalej na programie rozszerzonych aktualizacji bezpieczeństwa (ESU), który według doniesień z czerwca 2026 został dla użytkowników domowych przedłużony do **13 października 2027** — ale to ślepa ulica, nie rozwiązanie na stałe. *(Termin ESU zweryfikuj na stronie Microsoftu — źródła podają różnie, część starszych mówi o październiku 2026.)*

**Twój sprzęt spełnia wszystkie wymagania Windows 11:**

| Wymóg Windows 11 | Twój sprzęt | Stan |
|---|---|---|
| Procesor z listy Microsoft | Ryzen 7 5700X | ✅ na liście |
| 2+ rdzenie, 1+ GHz | 8 rdzeni / 16 wątków | ✅ |
| 4+ GB RAM | 32 GB | ✅ |
| 64+ GB dysk systemowy | ✅ | ✅ |
| **TPM 2.0** | fTPM w procesorze — **wyłączone** | ⚠️ do włączenia (krok 4) |
| **Secure Boot** | obsługiwane przez B550 — **wyłączone** | ⚠️ do włączenia (krok 5) |
| **UEFI + dysk GPT** | do sprawdzenia | ⚠️ krok 1 i 2 |
| DirectX 12 + WDDM 2.0 | RTX 3070 Ti | ✅ |

Czyli: nie musisz nic kupować. Trzy ustawienia w BIOS-ie i ewentualnie jedna konwersja dysku.

**Ile to zajmie:** BIOS ~20 minut. Konwersja MBR→GPT ~10 minut. Sama aktualizacja Windowsa 40–90 minut (w tle, komputer da się używać przez większość czasu).

---

## KROK 0 — zabezpiecz się (NIE POMIJAJ)

### 0a. ⚠️ NAJWAŻNIEJSZE: sprawdź, czy dysk nie jest zaszyfrowany

Jeśli dysk C: jest zaszyfrowany (BitLocker albo „Szyfrowanie urządzenia” w Windows 10 Home), to **zmiana ustawień TPM/Secure Boot w BIOS-ie zablokuje system** i przy starcie zażąda 48-cyfrowego klucza odzyskiwania. Bez niego **nie wejdziesz do Windowsa**.

Sprawdź — PowerShell **jako administrator**:
```powershell
manage-bde -status C:
```
Szukaj linii **Conversion Status** / **Stan konwersji**:
- `Fully Decrypted` / `W pełni odszyfrowany` → **OK, nic nie robisz**
- `Fully Encrypted` / `W pełni zaszyfrowany` → **zrób jedno z dwóch, zanim ruszysz BIOS:**

**Opcja A (prostsza) — wstrzymaj ochronę na czas zmian:**
```powershell
manage-bde -protectors -disable C: -RebootCount 3
```
To wstrzymuje BitLockera na 3 restarty — wystarczy na zmiany w BIOS-ie. Po wszystkim włącz z powrotem:
```powershell
manage-bde -protectors -enable C:
```

**Opcja B — zapisz klucz odzyskiwania:**
```powershell
manage-bde -protectors -get C: -type RecoveryPassword
```
Przepisz 48-cyfrowy klucz **na papier albo do telefonu** (nie na ten komputer!).
Możesz go też znaleźć na https://aka.ms/myrecoverykey (jeśli logujesz się kontem Microsoft).

### 0b. Punkt przywracania systemu
1. Start → `Utwórz punkt przywracania`
2. Dysk `C:` → **Konfiguruj** → *Włącz ochronę systemu* → OK
3. **Utwórz…** → nazwa: `przed BIOS i Win11` → **Utwórz**

### 0c. Kopia ważnych plików
Punkt przywracania **nie chroni twoich plików**. Przed konwersją MBR→GPT (krok 2) skopiuj na dysk D: (HDD 6 TB) albo na pendrive:
- dokumenty, zdjęcia, zapisy gier
- hasła / menedżer haseł

Konwersja MBR→GPT jest w praktyce bezpieczna, ale operuje na tablicy partycji dysku systemowego. Kopia zapasowa to pięć minut, a odzyskiwanie danych — tydzień.

### 0d. Zapisz obecne ustawienia BIOS-u
W BIOS-ie wejdź w **Save & Exit** → **Save Profiles** → zapisz obecny profil pod nazwą np. `PRZED_ZMIANAMI`. Jak coś pójdzie nie tak, wrócisz jednym kliknięciem (**Load Profiles**).

---

## KROK 1 — sprawdź, co masz

Najprościej: **uruchom `diagnoza.ps1`** i zajrzyj do `raport.txt` na Pulpicie, sekcje:
- **„2. PROCESOR / PLYTA GLOWNA / BIOS”** → wersja BIOS, tryb firmware
- **„6. DYSKI…”** → `Tablica partycji: GPT` albo `MBR`
- **„8. GOTOWOSC DO WINDOWS 11”** → TPM, Secure Boot, GPT

Ręcznie, jeśli wolisz:

**Tryb firmware (UEFI czy Legacy):**
Start → `msinfo32` → szukaj **Tryb systemu BIOS**
- `UEFI` → ✅ dobrze
- `Starsza wersja` / `Legacy` → ⚠️ potrzebna konwersja (krok 2)

**Styl partycji dysku systemowego:**
Start → `diskmgmt.msc` → prawy klik na **„Dysk 0”** (po lewej, na szarym polu) → **Właściwości** → zakładka **Woluminy** → **Styl partycji**
- `Tabela partycji GUID (GPT)` → ✅ dobrze, pomiń krok 2
- `Główny rekord rozruchowy (MBR)` → ⚠️ krok 2

**TPM:**
Start → `tpm.msc`
- „Nie można znaleźć zgodnego modułu TPM” → fTPM wyłączony (krok 4)
- jeśli jest: sprawdź **Wersja specyfikacji** — musi być **2.0**

**Oficjalny test Microsoftu:**
Pobierz **PC Health Check / Kontrola kondycji komputera**: https://aka.ms/GetPCHealthCheckApp
→ przycisk **Sprawdź teraz** — powie dokładnie, czego brakuje.

---

## KROK 2 — MBR → GPT (jeśli trzeba)

> **Pomiń ten krok, jeśli dysk systemowy ma już GPT.**

### ⚠️ Zanim zaczniesz
- [ ] Kopia danych zrobiona (krok 0c)
- [ ] BitLocker odszyfrowany albo wstrzymany (krok 0a)
- [ ] Dysk systemowy ma **maksymalnie 3 partycje** (narzędzie Microsoftu nie przerobi więcej). Sprawdź w `diskmgmt.msc`. Jeśli masz 4+ — usuń niepotrzebne (np. starą partycję odzyskiwania producenta), albo rób to przez reinstalację.
- [ ] **Nie restartuj komputera po konwersji, dopóki nie przełączysz BIOS-u na UEFI** (opisane niżej) — inaczej Windows nie wystartuje.

### 2a. Sprawdzenie (nic nie zmienia)

Otwórz **Wiersz polecenia jako administrator** (Start → `cmd` → prawy klik → *Uruchom jako administrator*):
```
mbr2gpt /validate /allowFullOS
```
- `Validation completed successfully` → możesz konwertować
- błąd → **nie konwertuj**. Najczęstsze powody: więcej niż 3 partycje, BitLocker aktywny, brak miejsca na nagłówek GPT. Napisz mi, co dokładnie pokazało.

### 2b. Konwersja

```
mbr2gpt /convert /allowFullOS
```
Trwa kilkadziesiąt sekund. Na końcu: `Conversion completed successfully`.

Narzędzie **zachowuje wszystkie dane i partycje** — przerabia tylko tablicę partycji i tworzy partycję EFI.

### 2c. Natychmiast przełącz BIOS na UEFI

**Nie uruchamiaj jeszcze Windowsa normalnie.** Zrestartuj i wejdź od razu do BIOS-u (klawisz **Del** przy starcie):

1. Naciśnij **F2**, żeby przejść z *Easy Mode* do **Advanced Mode** (jeśli trafiłeś w Easy Mode)
2. `BIOS` → **CSM Support** → **Disabled**
   *(CSM = tryb zgodności ze starym BIOS-em. Wyłączenie go = czysty UEFI. Dopiero po tym pojawi się opcja Secure Boot.)*
3. `Boot` → **Boot Option #1** → wybierz pozycję z przedrostkiem **„Windows Boot Manager”** lub **„UEFI: …”** (nie samą nazwę dysku)
4. **F10** → **Yes** → zapisz i wyjdź

Windows powinien wystartować normalnie. Sprawdź w `msinfo32`, że **Tryb systemu BIOS** = `UEFI`.

> Oficjalna dokumentacja mbr2gpt: https://learn.microsoft.com/windows/deployment/mbr-to-gpt

---

## KROK 3 — aktualizacja BIOS-u (zalecana przed fTPM)

**Dlaczego to robimy:** starsze wersje AGESA miały błąd, w którym **włączony fTPM powodował regularne mikroprzycinki i zawieszki** na płytach AMD (fTPM odwoływał się do pamięci SPI). AMD naprawiło to w AGESA 1.2.0.7 i nowszych. Skoro włączasz fTPM i zależy ci na płynności — zaktualizuj BIOS najpierw.

Jeśli `diagnoza.ps1` pokazuje BIOS z 2023 roku lub nowszy, prawdopodobnie masz już poprawkę — ale aktualizacja i tak daje lepsze wsparcie dla Ryzena 5000 i stabilniejsze XMP.

### 3a. Pobierz właściwy plik

1. Wejdź na https://www.gigabyte.com/ → **Support** → wpisz **B550 GAMING X V2**
2. ⚠️ **Sprawdź rewizję płyty** — jest nadrukowana na laminacie przy gniazdach PCIe (np. „Rev. 1.0”, „Rev. 1.1”). Pobierz BIOS dla **swojej** rewizji.
3. Zakładka **BIOS** → pobierz najnowszą wersję (plik .zip)
4. Rozpakuj — w środku jest plik bez rozszerzenia albo z rozszerzeniem typu `.F17`

### 3b. Przygotuj pendrive

- Pendrive **sformatowany w FAT32** (nie NTFS, nie exFAT)
- Skopiuj rozpakowany plik BIOS **do katalogu głównego** pendrive'a (nie do folderu)

### 3c. Aktualizacja przez Q-Flash

1. Włóż pendrive do **tylnego** portu USB
2. Restart → **Del** → wejdź do BIOS-u
3. **Advanced Mode (F2)** → zakładka **Tools** (lub **Tool**) → **Q-Flash**
   *(skrót: klawisz **F8** w BIOS-ie otwiera Q-Flash bezpośrednio)*
4. Wybierz pendrive → wybierz plik BIOS → **Start**
5. ⛔ **NIE WYŁĄCZAJ KOMPUTERA, NIE ODŁĄCZAJ PRĄDU.** Trwa 2–5 minut, komputer kilka razy sam się zrestartuje i ekran może zgasnąć. To normalne.
6. Po zakończeniu BIOS wróci do ustawień domyślnych — **wszystkie twoje ustawienia (w tym XMP) wrócą do fabrycznych**

### 3d. Po aktualizacji — od razu ustaw podstawy

W BIOS-ie, zanim wyjdziesz:
- `Tweaker` → **XMP / X.M.P.** → **Profile1** ← włącz XMP, jeśli raport z `diagnoza.ps1` pokazał, że pamięć chodzi na 2133/2400/2666 MT/s
- `BIOS` → **CSM Support** → **Disabled** (jeśli zrobiłeś krok 2)
- przejdź do kroków 4 i 5 — i tak już jesteś w BIOS-ie

> Nie używaj **@BIOS** (aktualizacja z Windowsa) — jest mniej pewna niż Q-Flash z pendrive'a.
> **Q-Flash Plus** (przycisk na tylnym panelu, aktualizacja bez procesora) to opcja ratunkowa — plik musi się wtedy nazywać `GIGABYTE.bin`.

---

## KROK 4 — włącz fTPM w BIOS

fTPM to TPM 2.0 zrealizowany w samym procesorze Ryzen. Nie musisz kupować żadnego modułu.

1. Restart → **Del** przy starcie → BIOS
2. **F2** → *Advanced Mode*
3. Zakładka **Settings** → **Miscellaneous**
4. Znajdź **AMD CPU fTPM** → ustaw na **Enabled**

   Na niektórych wersjach BIOS-u opcja nazywa się inaczej — szukaj też:
   - `Settings` → `Miscellaneous` → **AMD CPU fTPM**
   - `Settings` → `Miscellaneous` → `Trusted Computing` → **Security Device Support** → `Enable`
   - `Settings` → `AMD CBS` → `CPU Common Options` → **TPM Device Selection** → `AMD CPU fTPM`

5. **F10** → **Yes** (zapisz i wyjdź)

### Co się stanie po pierwszym starcie
Może pojawić się komunikat o **wyczyszczeniu fTPM** („fTPM/PSP NV corrupted” lub pytanie o reset). Jeśli **nie masz BitLockera**, wybierz opcję resetu/kontynuacji — nic nie tracisz. Jeśli masz BitLockera i nie wstrzymałeś go w kroku 0a, **przygotuj klucz odzyskiwania**.

---

## KROK 5 — włącz Secure Boot w BIOS

> ⚠️ **Kolejność ma znaczenie.** Secure Boot zadziała tylko wtedy, gdy Windows jest już zainstalowany w trybie **UEFI na dysku GPT**. Jeśli nie zrobiłeś kroku 2 i masz MBR/Legacy — **najpierw krok 2**, inaczej po włączeniu Secure Boot komputer nie wystartuje.

1. Restart → **Del** → BIOS → **F2** (*Advanced Mode*)
2. Zakładka **BIOS** → **CSM Support** → **Disabled**
   *(bez tego opcja Secure Boot będzie wyszarzona albo niewidoczna)*
3. **F10** → zapisz i zrestartuj → wróć do BIOS-u
   *(czasem trzeba restartu, żeby opcje Secure Boot się pojawiły)*
4. Zakładka **BIOS** → **Secure Boot**
5. Ustaw:
   - **Secure Boot Enable** → **Enabled**
   - **Secure Boot Mode** → **Standard**
6. Jeśli widzisz **Secure Boot State: Disabled** albo komunikat o braku kluczy:
   → **Key Management** → **Restore Factory Keys** (albo *Install Default Secure Boot Keys* / *Enroll Platform Key*) → potwierdź
7. **F10** → **Yes**

Komputer powinien wystartować normalnie. Jeśli nie — patrz [Ratunek](#ratunek).

---

## KROK 6 — sprawdź w Windowsie

Trzy sprawdzenia:

**1. TPM 2.0**
Start → `tpm.msc`
- Powinno być: **„Modułu TPM jest gotowy do użycia”**
- W sekcji *Informacje o producencie modułu TPM* → **Wersja specyfikacji: 2.0** ✅

**2. Secure Boot i tryb UEFI**
Start → `msinfo32`
- **Tryb systemu BIOS**: `UEFI` ✅
- **Stan bezpiecznego rozruchu**: `Włączone` ✅

**3. Oficjalny test**
Uruchom **PC Health Check** → **Sprawdź teraz**
- Powinno być: **„Ten komputer spełnia wymagania systemu Windows 11”** ✅

Albo uruchom ponownie `diagnoza.ps1` (jako administrator) i sprawdź sekcję 8.

**Przy okazji:** jeśli raport pokazywał, że pamięć chodzi na 2133/2666 MT/s — wróć do BIOS-u i włącz **XMP → Profile1** (`Tweaker` → `X.M.P.`). Na Ryzenie to jedna z największych darmowych poprawek wydajności. Po włączeniu przetestuj stabilność (np. 15 minut w grze). Jeśli komputer się zawiesza — wyłącz XMP albo zejdź na Profile2 / ręcznie na 3000 MT/s.

---

## KROK 7 — aktualizacja do Windows 11

**To jest darmowe.** Twoja licencja Windows 10 jest przypisana do płyty głównej i przechodzi na Windows 11 automatycznie. Nie podawaj klucza, nie kupuj niczego, nie korzystaj z „tanich kluczy z Allegro”.

### Droga 1 (zalecana) — Windows Update

`Ustawienia` → `Aktualizacja i zabezpieczenia` → `Windows Update` → **Sprawdź aktualizacje**

Jeśli sprzęt jest zgodny, pojawi się kafelek **„Aktualizacja do systemu Windows 11 jest gotowa — i jest bezpłatna!”** → **Pobierz i zainstaluj**.

Może nie pojawić się od razu (Microsoft wypuszcza falami). Jeśli nie ma go po 1–2 dniach, użyj drogi 2.

### Droga 2 — Asystent instalacji Windows 11

**Jedyne oficjalne źródło:** https://www.microsoft.com/software-download/windows11

Na tej stronie są trzy narzędzia — **użyj pierwszego**:
1. **Asystent instalacji systemu Windows 11** ← to, aktualizacja w miejscu, zachowuje pliki i programy
2. Narzędzie do tworzenia nośnika (dla instalacji z pendrive'a)
3. Obraz ISO

Uruchom Asystenta → **Zaakceptuj i zainstaluj** → poczekaj (40–90 minut, kilka restartów).

Przy pytaniu **„Co zachować”** wybierz **„Zachowaj pliki osobiste i aplikacje”**.

### ⚠️ Czego nie robić

- ❌ **Nie używaj Rufusa z opcją „omiń TPM/Secure Boot”** ani wpisów `LabConfig`/`BypassTPMCheck` w rejestrze. Skoro twój sprzęt spełnia wymagania legalnie — nie ma po co. Instalacje z obejściem nie dostają części aktualizacji funkcji.
- ❌ **Nie pobieraj „Windows 11 Lite”, „Ghost Spectre”, „Tiny11”** ani innych przeróbek. Mają wyłączone aktualizacje i usunięte komponenty bezpieczeństwa.
- ❌ **Nie kupuj kluczy Windows 11** — nie potrzebujesz żadnego.
- ❌ **Nie wyłączaj Windows Update, Defendera ani zapory** przed aktualizacją ani po niej.

---

## KROK 8 — po aktualizacji

### 8a. Masz 10 dni na powrót
Jeśli coś ci się nie spodoba: `Ustawienia` → `System` → `Odzyskiwanie` → **Powrót** (dostępne 10 dni od aktualizacji, potem Windows usuwa pliki starej wersji).

### 8b. Zaktualizuj sterowniki
1. **Chipset AMD** — https://www.amd.com/support (najpierw to, poprawia zarządzanie energią i harmonogram rdzeni na Ryzenie)
2. **NVIDIA** — https://www.nvidia.com/Download/index.aspx → *Instalacja niestandardowa* → *Wykonaj czystą instalację*
3. **Płyta B550** — https://www.gigabyte.com/ → Support → B550 GAMING X V2 → zakładka *Driver* (audio Realtek, LAN)
4. **Windows Update** → *Opcje zaawansowane* → **Opcjonalne aktualizacje** → sterowniki

### 8c. Sprawdź, czy nie wróciły ustawienia domyślne
Po dużej aktualizacji Windows potrafi zresetować:
- odświeżanie monitorów → ustaw ponownie **240 Hz** na MSI i **200 Hz** na G27Q2
- **HAGS** (planowanie GPU) → sprawdź, czy włączone
- **Tryb gry** → sprawdź, czy włączony
- G-Sync w panelu NVIDII

Wszystko to jest opisane w `USTAWIENIA.md`, rozdział 6.

### 8d. Zrób nowy punkt przywracania
Windows 11 po aktualizacji może mieć wyłączoną ochronę systemu. Start → `Utwórz punkt przywracania` → `C:` → **Konfiguruj** → *Włącz* → **Utwórz** → `czysty Windows 11`.

### 8e. Dopiero teraz instaluj Veyrę
Wróć do `USTAWIENIA.md`, rozdział 4.

---

## Ratunek

### Komputer nie startuje po włączeniu Secure Boot
Najczęstsza przyczyna: Windows jest zainstalowany w trybie Legacy/MBR.
1. Wyłącz komputer przyciskiem (przytrzymaj 5 s)
2. Włącz → **Del** → BIOS
3. `BIOS` → **Secure Boot Enable** → **Disabled**
4. `BIOS` → **CSM Support** → **Enabled**
5. **F10** → zapisz
6. Po wejściu do Windowsa → wróć do **kroku 2** (MBR→GPT) i zrób go najpierw

Albo szybciej: **Save & Exit** → **Load Profiles** → wczytaj profil `PRZED_ZMIANAMI` z kroku 0d.

### Windows żąda klucza odzyskiwania BitLocker
Nie panikuj, dane są całe.
- Wpisz 48-cyfrowy klucz z kroku 0a
- Nie masz go pod ręką? → https://aka.ms/myrecoverykey (zaloguj się kontem Microsoft na telefonie)
- Po wejściu do systemu: `manage-bde -protectors -disable C: -RebootCount 3`, dokończ zmiany w BIOS-ie, potem `manage-bde -protectors -enable C:`

### Mikroprzycinki po włączeniu fTPM
To stary błąd AGESA. Rozwiązanie: **zaktualizuj BIOS** (krok 3). Nie wyłączaj fTPM — bez niego nie ma Windows 11.

### Po aktualizacji BIOS-u komputer nie startuje / czarny ekran
1. Odłącz kabel zasilania
2. Wyjmij baterię CMOS (okrągła, CR2032) na 60 sekund **albo** zewrzyj zworkę **CLR_CMOS** na płycie
3. Włóż baterię, podłącz prąd, włącz → BIOS wróci do ustawień fabrycznych
4. Ustaw ponownie: XMP, CSM Disabled, fTPM, Secure Boot

Jeśli nadal nie startuje — użyj **Q-Flash Plus** (przycisk na tylnym panelu I/O): pendrive FAT32 z plikiem BIOS przemianowanym na `GIGABYTE.bin`, włóż w port oznaczony „Q-Flash Plus / BIOS”, naciśnij przycisk, poczekaj na miganie diody do zgaśnięcia.

### PC Health Check nadal mówi, że sprzęt jest niezgodny
Sprawdź dokładnie, o który punkt mu chodzi (aplikacja to pokazuje):
- **TPM** → krok 4, potem sprawdź `tpm.msc` → wersja musi być **2.0**
- **Secure Boot** → krok 5, potem `msinfo32` → *Stan bezpiecznego rozruchu: Włączone*
- **Partycja GPT / UEFI** → krok 2
- **Procesor** → Ryzen 7 5700X jest na oficjalnej liście, więc to nie on

---

## Źródła

- Microsoft — konwersja MBR→GPT narzędziem `mbr2gpt`: https://learn.microsoft.com/windows/deployment/mbr-to-gpt
- Microsoft — pobieranie Windows 11 (Asystent instalacji, oficjalne źródło): https://www.microsoft.com/software-download/windows11
- Microsoft — PC Health Check / Kontrola kondycji komputera: https://aka.ms/GetPCHealthCheckApp
- Microsoft — odnajdywanie klucza odzyskiwania BitLocker: https://aka.ms/myrecoverykey
- Gigabyte — wsparcie dla B550 GAMING X V2 (BIOS i sterowniki, wybierz swoją rewizję): https://www.gigabyte.com/
- AMD — sterowniki chipsetu: https://www.amd.com/support
- Windows 10 ESU przedłużone dla użytkowników domowych do 13.10.2027 (doniesienia, zweryfikuj u Microsoftu): https://www.windowslatest.com/2026/06/25/windows-10-support-quietly-extended-until-oct-2027-as-users-reject-windows-11/
- Veyra NR — wymóg Windows 11 x64 + DirectX 12: https://github.com/Likely7/Veyra-NRVideo
