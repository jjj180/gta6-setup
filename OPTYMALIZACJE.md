# OPTYMALIZACJE.md — najlepsze optymalizacje i czyszczenie pod twój sprzęt

Dla: **Ryzen 7 5700X · RTX 3070 Ti 8 GB · 32 GB RAM · Gigabyte B550 Gaming X V2 · MSI MAG 271QP QD-OLED 1440p 240 Hz · Gigabyte G27Q2 1440p 200 Hz · D: = HDD 6 TB · NZXT Kraken**
Pod: **grę z PS5 przez kartę przechwytującą + generowanie klatek** (ale też normalne granie na PC)

Wszystko tutaj jest **posortowane od największego zysku do najmniejszego**. Nie rób wszystkiego po kolei — zrób TOP 8, zmierz, a resztę tylko jeśli chcesz.

---

## Najpierw: czego tu nie znajdziesz

Przeszukałem dziesiątki źródeł i **świadomie odrzuciłem** wszystko, co jest mitem albo szkodzi. Lista z uzasadnieniami jest na końcu (rozdział H). W skrócie: żadnych czyszczeń rejestru, żadnych „boosterów”, żadnego grzebania w `bcdedit`, żadnego wyłączania Defendera, zapory ani aktualizacji, żadnych skryptów „debloat”, które usuwają Microsoft Store.

**Każda zmiana zaczyna się od punktu przywracania.** Start → `Utwórz punkt przywracania` → dysk C: → **Utwórz**.

---

## TOP 8 — to daj sobie zrobić, resztę możesz pominąć

| # | Co | Gdzie | Zysk | Trudność |
|---|---|---|---|---|
| 1 | **XMP + FCLK 1:1** | BIOS | **5–15% FPS** w grach zależnych od CPU | łatwe |
| 2 | **Sterownik AMD chipset + plan Zrównoważony** | Windows | stabilniejsze taktowania, mniej mikroprzycinków | łatwe |
| 3 | **Undervolt GPU (krzywa ~0,90–0,95 V)** | MSI Afterburner | **−10 do −15 °C, −60 do −80 W**, ten sam FPS | średnie |
| 4 | **Resizable BAR** | BIOS + sprawdzenie | 0–8% w zależności od gry, darmowe | łatwe |
| 5 | **PBO + Curve Optimizer −15** | BIOS | **niższe temperatury + wyższy boost** | średnie |
| 6 | **OLED Care na monitorze** | OSD monitora | chroni panel wart 1500+ zł | łatwe |
| 7 | **Czyszczenie: cleanmgr + DISM + autostart** | Windows | 10–40 GB miejsca, szybszy start | łatwe |
| 8 | **Wyłączenie nakładek i nagrywania w tle** | NVIDIA / Windows | mniej przycinek, mniej zużytego VRAM | łatwe |

Pozycje 1, 3 i 5 to **największe darmowe zyski, jakie można wycisnąć z tego konkretnego zestawu.** Pozycje 2, 4, 7, 8 to 10 minut pracy każda.

---

# CZĘŚĆ A — BIOS (tu są największe pieniądze)

Wejście do BIOS-u: restart → **Del** przy starcie → **F2** przełącza na *Advanced Mode*.
Przed zmianami: **Save & Exit** → **Save Profiles** → zapisz obecny profil jako `PRZED_OPT`.

## A1. ⭐ XMP + FCLK — najważniejsza rzecz na całej liście

Jeśli `diagnoza.ps1` pokaże, że pamięć chodzi na **2133 / 2400 / 2666 MT/s**, to twoje 32 GB pracuje na ustawieniach awaryjnych i tracisz nawet **15% FPS** w grach obciążających procesor. Na Ryzenie pamięć jest bezpośrednio powiązana z Infinity Fabric — to nie jest „drobny tweak”.

1. `Tweaker` → **X.M.P. / XMP Profile** → **Profile1**
2. Zapisz (**F10**), uruchom Windows, sprawdź w raporcie, że pamięć chodzi na pełnej prędkości
3. **Sprawdź FCLK:** `Tweaker` → `Advanced CPU Settings` (albo `AMD Overclocking` → `DDR and Infinity Fabric Frequency`) → **Infinity Fabric Frequency (FCLK)**

   | Pamięć | FCLK powinien być |
   |---|---|
   | DDR4-3200 | **1600 MHz** |
   | DDR4-3600 | **1800 MHz** |
   | DDR4-3733+ | zostaw 1800 i pamięć na 3600 — wyżej Ryzen 5000 traci na trybie 2:1 |

   Zasada: **FCLK = połowa prędkości pamięci.** To tryb 1:1, najszybszy. Jeśli BIOS ustawi FCLK „Auto” i wyjdzie inna wartość — wpisz ręcznie.

4. **Test stabilności:** uruchom `mdsched.exe` (Narzędzie diagnostyki pamięci Windows) albo zagraj 30 minut. Jeśli komputer się zawiesza / niebieski ekran → wróć na Profile2 albo ustaw ręcznie 3000 MT/s.

> Dlaczego to działa tak mocno: 5700X ma jedno CCD, więc nie masz problemu z opóźnieniem między chipletami — ale masz pełną zależność od prędkości pamięci przy dostępie do kontrolera. Przy przechwytywaniu obrazu z karty dochodzi jeszcze stały transfer przez USB do RAM, więc pasmo pamięci ma tu podwójne znaczenie.

## A2. ⭐ PBO + Curve Optimizer (undervolt procesora)

Efekt: **niższe temperatury i JEDNOCZEŚNIE wyższy boost**. Nie ma tu kompromisu — Ryzen 5000 boostuje tym wyżej, im chłodniej i im mniej napięcia potrzebuje.

1. `Tweaker` → **Advanced CPU Settings** → **Precision Boost Overdrive** → **Advanced**
2. **PBO Limits** → `Motherboard` (albo ręcznie: PPT 120 W / TDC 75 A / EDC 110 A — to bezpieczne wartości dla B550 Gaming X V2 i 5700X)
3. **Curve Optimizer** → `All Cores` → **Negative** → **Magnitude: 15**
4. **Max CPU Boost Clock Override**: na start **zostaw 0 / Auto**

   Boost override i agresywny undervolt **walczą ze sobą** — im więcej boostu wymusisz, tym mniej zostaje zapasu na undervolt. Najpierw ustabilizuj krzywą, dopiero potem ewentualnie dodaj +100 MHz.

5. **F10**, uruchom Windows, przetestuj:
   - **OCCT** (https://www.ocbase.com/) — tryb *CPU, Variable load* albo *Linpack*, 30 minut
   - albo **CoreCycler** (https://github.com/sp00n/corecycler) — testuje każdy rdzeń osobno, znajduje jeden niestabilny rdzeń, czego testy wielowątkowe nie wykrywają
   - plus **Cinebench R23** wielowątkowo, 10 minut

6. **Jeśli stabilne** → spróbuj **−20**, przetestuj ponownie. Stabilne → **−25**.
   **Jeśli niestabilne** (zawieszki, błędy w CoreCycler, restart przy małym obciążeniu w Windowsie) → wróć o 5 w górę.

   Realne wartości z forów dla 5700X: **−15 bezpiecznie, −20 do −23 typowo, −25 często już za dużo.** Jeden użytkownik 5700X raportował crash przy −25 i stabilność przy −23.

> ⚠️ **Pułapka diagnostyczna:** jeśli krzywa wygląda stabilnie tylko po wyłączeniu C-states — to znaczy, że jest nadal **za agresywna**. Nie wyłączaj C-states, żeby ukryć problem. Zejdź z undervoltem.

> ⚠️ Niestabilny Curve Optimizer objawia się **nie pod obciążeniem, a na pulpicie** — losowe zawieszki przy małym obciążeniu, gdy procesor schodzi na niskie napięcia. Dlatego CoreCycler > Cinebench.

## A3. Resizable BAR

Darmowe 0–8% w części gier (w niektórych 0%, w paru nawet lekki minus — ale średnio na plus).

1. `BIOS` → **CSM Support** → **Disabled** *(bez tego Above 4G Decoding nie zadziała)*
2. `Settings` → `IO Ports` → **Above 4G Decoding** → **Enabled**
3. `Settings` → `IO Ports` → **Re-Size BAR Support** → **Auto** (albo Enabled)
4. **F10**
5. **Sprawdź w Windowsie:** Panel sterowania NVIDIA → **Informacje o systemie** (lewy dolny róg) → szukaj **Resizable BAR: Tak**

Wymagania:
- BIOS płyty **F12 lub nowszy** (Gigabyte podaje F12 jako minimum dla B550) — sprawdź wersję w raporcie z `diagnoza.ps1`
- Dysk systemowy w **GPT** + tryb **UEFI** (patrz `BIOS_WIN11.md`)
- vBIOS karty — RTX 3070 Ti wyszła już po wprowadzeniu ReBAR, więc **najprawdopodobniej nie wymaga aktualizacji**. Jeśli Panel NVIDII mówi „Nie”, a w BIOS-ie wszystko włączone → jest [narzędzie NVIDII do aktualizacji vBIOS](https://nvidia.custhelp.com/app/answers/detail/a_id/5165/), ale rób to tylko jeśli naprawdę trzeba.

## A4. Pozostałe ustawienia BIOS — ustaw raz i zapomnij

| Opcja | Gdzie | Ustaw | Dlaczego |
|---|---|---|---|
| **CPPC** | `Settings` → `AMD CBS` → `CPU Common Options` | **Enabled** | Windows wie, które rdzenie są najszybsze |
| **CPPC Preferred Cores** | tam samo | **Enabled** | Gry lądują na najlepszych rdzeniach |
| **Global C-state Control** | `Tweaker` → `Advanced CPU Settings` | **Enabled** | Potrzebne do działania boostu i Curve Optimizer. **Nie wyłączaj** |
| **Power Supply Idle Control** | tam samo | **Typical Current Idle** | Naprawia losowe wyłączenia/restarty przy bezczynności na Ryzenie |
| **SVM Mode** (wirtualizacja) | `Settings` → `Miscellaneous` | **Enabled** tylko jeśli używasz WSL/maszyn wirtualnych; inaczej **Disabled** | Włączona wirtualizacja + VBS = utrata wydajności |
| **ErP** | `Settings` → `Platform Power` | **Disabled** | Włączone odcina zasilanie portów USB po wyłączeniu — grabber może nie być widziany |
| **PCIe slot configuration** (slot GPU) | `Settings` → `IO Ports` | **Gen4** | 3070 Ti to Gen4 x16 |
| **SMT** | `Tweaker` → `Advanced CPU Settings` | **Enabled** | Nigdy nie wyłączaj na 8-rdzeniowcu |
| **HD Audio Controller** | `Settings` → `IO Ports` | Enabled | — |
| **Smart Fan 5** | `Fan` (klawisz **F6**) | patrz niżej | — |

**Krzywa wentylatorów (Smart Fan 5 / klawisz F6):**
- **CPU_FAN / pompa Krakena** → tryb **Full Speed** albo stałe 100% (pompa AIO ma chodzić na stałych obrotach, nie regulować)
- **SYS_FAN (wentylatory radiatora)** → krzywa oparta o **CPU Temperature**: 30 °C → 30% · 50 °C → 45% · 65 °C → 65% · 80 °C → 100%
- **Fan Stop** → wyłączone dla radiatora (wentylatory, które się zatrzymują i startują, są bardziej słyszalne niż te chodzące stale na niskich obrotach)
- **Temperature Interval** → 3–4 °C (zapobiega „pompowaniu” obrotów)

---

# CZĘŚĆ B — karta graficzna

## B1. ⭐ Undervolt / ograniczenie napięcia RTX 3070 Ti

To najlepsza optymalizacja GPU na tej karcie. 3070 Ti ma pamięć GDDR6X, która grzeje jak piec, i fabrycznie kartę skonfigurowano z zapasem napięcia „na wszelki wypadek”. Realne efekty z raportów użytkowników:

| Ustawienie | Pobór mocy | Temperatura | Wydajność |
|---|---|---|---|
| fabrycznie | ~290 W | ~76–82 °C | 100% |
| limit 0,95 V | ~240 W | <80 °C | ~100% |
| limit 0,90 V | ~215 W | ~70 °C | 98–100% |
| limit 0,85 V | ~204 W | ~67 °C | 95–98% |

**Jak to zrobić (MSI Afterburner, oficjalnie: https://www.msi.com/Landing/afterburner/graphics-cards):**

1. Zainstaluj MSI Afterburner (wersja z RivaTuner w pakiecie)
2. **Ctrl+F** → otwiera edytor krzywej napięcie/taktowanie
3. Znajdź punkt **900 mV**. Podnieś go do **~1875–1920 MHz** (kliknij punkt, strzałki w górę)
4. Zaznacz wszystkie punkty **po prawej** od 900 mV (Shift + klik na ostatnim) i naciśnij **Enter** — spłaszczy je do tej samej wysokości. Dzięki temu karta nigdy nie przekroczy 900 mV.
5. **Memory Clock: +500 MHz** (GDDR6X na 3070 Ti zwykle to bierze; jeśli widzisz artefakty albo spadek wydajności z powodu korekcji błędów — zejdź do +300, potem 0)
6. **Power Limit: zostaw 100%** (nie podnoś — chodzi o mniej ciepła, nie więcej)
7. **Zapisz do profilu** (kliknij dyskietkę → cyfrę 1) i zaznacz **„Apply at Windows startup”**
8. **Test:** 3DMark Time Spy **Stress Test** (20 pętli) albo Heaven/Superposition 30 minut. Dodatkowo zagraj 1 h — gry potrafią wywalić undervolt, którego benchmark nie ruszy.
9. Jeśli crash sterownika / artefakty → obniż taktowanie w punkcie 900 mV o 30 MHz i powtórz. Jeśli nadal → spróbuj 925 mV.

**W HWiNFO64 patrz na trzy temperatury, nie jedną:**
- GPU Temperature — poniżej 75 °C
- **GPU Hot Spot** — poniżej 95 °C
- **GPU Memory Junction (GDDR6X)** — **poniżej 95 °C**, to najsłabszy punkt 3070 Ti

> Dlaczego to ważne właśnie u ciebie: przy przechwytywaniu + generowaniu klatek GPU pracuje **non stop**, bez przerw między scenami. Karta siedzi w stanie ustalonym, więc temperatura pamięci ma czas narosnąć. Chłodniejsza karta = wyższe stabilne taktowania = mniej przycinek.

## B2. Czysta instalacja sterownika

1. Pobierz sterownik **tylko** z https://www.nvidia.com/Download/index.aspx albo przez **NVIDIA App**
2. Przy instalacji: **Instalacja niestandardowa** → zaznacz **Wykonaj czystą instalację**
3. Odznacz komponenty, których nie używasz

**Czy potrzebujesz DDU?** W 99% przypadków **nie** — opcja „czysta instalacja” w instalatorze NVIDII wystarcza, a sam autor DDU pisze, że narzędzie nie jest potrzebne przy każdej rutynowej aktualizacji.

Użyj DDU **tylko** jeśli masz objawy po stronie sterownika (crashe, czarne ekrany, pozostałości po starej karcie). Oficjalne źródło: https://www.wagnardsoft.com/ddu — **nie pobieraj z innych stron.**

> Uwaga: autor DDU zaleca dodanie jego folderu do wyjątków antywirusa. **Nie rób tego** — to łamie naszą zasadę. Zamiast tego: pobierz z oficjalnej strony, uruchom w **trybie awaryjnym** (DDU sam proponuje restart do trybu awaryjnego), a jeśli Defender coś zgłosi, nie obchodź go — po prostu pomiń DDU i użyj czystej instalacji z instalatora NVIDII.

## B3. Ustawienia w Panelu sterowania NVIDIA / NVIDIA App

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| **Tryb niskiego opóźnienia** | **Wł.** | „Ultra” przy generowaniu klatek bywa gorsze (koliduje z kolejką klatek programu) |
| **Tryb zarządzania energią** | **Preferuj maksymalną wydajność** | Trzyma zegary, zapobiega mikroprzycinkom przy zmiennym obciążeniu |
| **Synchronizacja pionowa** | **Wyłączona** | masz G-Sync |
| **Rozmiar pamięci podręcznej shaderów** | **10 GB** (lub max) | Mniej przycinek przy pierwszym wejściu w scenę. Trzymaj na SSD |
| **Potokowe przetwarzanie wątków** | Wł. | — |
| **Optymalizacja wielowyświetlaczowa** | **Tryb wydajności jednego wyświetlacza** — tylko jeśli odłączysz drugi monitor | Dwa monitory o różnym odświeżaniu (240 + 200 Hz) zmuszają kartę do wyższych zegarów pamięci na pulpicie. To normalne, nie błąd |
| **G-Sync** | `Skonfiguruj G-SYNC` → **Włącz dla trybu pełnoekranowego i okienkowego** | Okienkowy jest konieczny — Veyra i Lossless Scaling pracują w oknie |
| **Filtrowanie tekstur – jakość** | Wysoka wydajność | tu nieistotne |

**Wyłącz:** nakładkę w grze (ALT+Z), Instant Replay / ShadowPlay, filtry Freestyle, automatyczną optymalizację gier, RTX HDR i RTX Video dla przeglądarki.

> **Dlaczego drugi monitor podnosi zegary pamięci GPU na pulpicie:** przy dwóch monitorach o różnym odświeżaniu karta nie może zejść na najniższy stan pamięci. Objawia się to wyższą temperaturą i poborem na bezczynności. Jeśli ci to przeszkadza, ustaw oba monitory na **tę samą** częstotliwość (np. oba 200 Hz) — zegary pamięci spadną. Przy grze nie ma to znaczenia.

---

# CZĘŚĆ C — Windows

## C1. ⭐ Sterownik chipsetu AMD + plan zasilania

**Najpierw sterownik chipsetu:** https://www.amd.com/support → wybierz *Chipsets → AM4 → B550*

To nie jest „zwykły sterownik”. Zawiera **AMD Processor Power Management** — moduł, który decyduje, jak szybko procesor podnosi taktowania i na które rdzenie Windows wysyła pracę. Bez niego Ryzen reaguje wolniej i boostuje niżej.

**Plan zasilania: zostaw „Zrównoważony”.**

To brzmi kontrintuicyjnie, ale jest poprawne:
- Nowoczesny Ryzen używa **CPPC2**, który ramuje zegary sprzętowo — gra i tak dostaje pełny boost, niezależnie od planu
- „Wysoka wydajność” zmienia głównie zachowanie **na bezczynności**: procesor grzeje się i pobiera więcej prądu, nie robiąc nic
- „Wysoka wydajność” wyłącza też *core parking*, co na niektórych Ryzenach rozrzuca wątki gry szerzej, niż trzeba

Czyli: **Zrównoważony** (albo „AMD Ryzen Balanced”, jeśli sterownik chipsetu go doda). Testuj „Wysoka wydajność” tylko jeśli konkretna gra przycina.

❌ **Nie włączaj „Ultimate Performance”** — nie daje nic w grach na Ryzenie, a podnosi pobór na bezczynności.

Jedna rzecz warta zmiany w planie: `Panel sterowania` → `Opcje zasilania` → `Zmień zaawansowane ustawienia` → **Dysk twardy** → *Wyłącz dysk twardy po* → **0 (nigdy)**. Twój D: to HDD 6 TB — zasypianie i wybudzanie talerzy powoduje sekundowe zawieszki.

## C2. Ustawienia grania

| Gdzie | Ustaw |
|---|---|
| `Ustawienia` → `Gry` → **Tryb gry** | **Włączony** |
| `Ustawienia` → `Gry` → **Przechwytywanie** (Game DVR) | **Wyłączone** — nagrywanie w tle zjada wydajność |
| `Ustawienia` → `Gry` → **Pasek gier Xbox** | **Wyłączony** |
| `Ustawienia` → `System` → `Ekran` → `Grafika` → `Zmień domyślne ustawienia grafiki` | patrz C3 i C4 |
| `Ustawienia` → `Personalizacja` → `Pasek zadań` → **Widżety** | Wyłączone |
| `Ustawienia` → `Personalizacja` → `Pasek zadań` → **Wyszukiwanie** | „Tylko ikona” lub ukryte |

## C3. ⚠️ HAGS — u ciebie to NIE jest „po prostu włącz”

`Ustawienia` → `System` → `Ekran` → `Grafika` → `Zmień domyślne ustawienia grafiki` → **Planowanie GPU z akceleracją sprzętową**

**HAGS rezerwuje do ~1 GB VRAM** na kolejki poleceń po stronie karty. Na karcie z 8 GB, która już dostaje po głowie od generowania klatek (sama Veyra rezerwuje dodatkowo 1,3–2,3 GB na budżet opóźnienia), to może **wywołać więcej przycinek, niż usuwa**.

Z drugiej strony HAGS poprawia tempo klatek i opóźnienie na nowoczesnych kartach i jest wymagany przez część technik generowania klatek.

**Dlatego: przetestuj A/B, nie zgaduj.**

1. Włącz HAGS → restart → zagraj 20 minut → zapisz wynik (CapFrameX albo licznik FPS + obserwacja mikroprzycinek)
2. Wyłącz HAGS → restart → zagraj te same 20 minut w tym samym miejscu
3. **Zostaw to, co dało równiejsze tempo**, nie to, co dało wyższy średni FPS

Jeśli nie chcesz testować: na 8 GB VRAM z generowaniem klatek **postaw na wyłączone** jako bezpieczniejszy wybór.

## C4. ⚠️ „Optymalizacje dla gier okienkowych” — też A/B

Ta sama ścieżka: `Grafika` → `Zmień domyślne ustawienia grafiki` → **Optymalizacje dla gier okienkowych** (tylko Windows 11).

Funkcja przenosi gry DX10/DX11 w oknie na szybszą ścieżkę wyświetlania (flip model) i zbliża opóźnienie okna do pełnego ekranu. **Dla ciebie teoretycznie idealne** — Veyra i Lossless Scaling działają właśnie w oknie.

ALE: od 24H2 są zgłoszenia, że ta opcja **powoduje przycinki i nierówne tempo klatek** w części tytułów. Źródła są podzielone.

**Przetestuj A/B tak samo jak HAGS.** Jeśli widzisz nierówne tempo — wyłącz.

## C5. VBS / Integralność pamięci — fakty, decyzja twoja

`Ustawienia` → `Prywatność i zabezpieczenia` → `Zabezpieczenia Windows` → `Zabezpieczenia urządzenia` → `Izolacja rdzenia` → **Integralność pamięci**

**To jest prawdziwa funkcja bezpieczeństwa** (blokuje wstrzykiwanie złośliwych sterowników do jądra), więc nie powiem ci „wyłącz to”. Podaję liczby i decydujesz sam:

| Pomiar | Koszt wydajności |
|---|---|
| Nowe testy na nowoczesnych CPU (Cyberpunk 2077, 1080p low) | ~1,9% średni FPS, ~6,6% w 1% najniższych |
| Counter-Strike 2, 1080p low | ~1,7% |
| **Ryzen 7 5800X przy 1280×720 (skrajnie zależne od CPU)** | **~6% średni FPS, ~8% czasy klatek** |
| Stare testy z 2021 (i7-12700KF, 10 gier) | ~7% średnio, ~15% w 1% najniższych |

Sprzętowy mechanizm **MBEC** w nowszych procesorach mocno zmniejszył ten koszt — dlatego nowe testy pokazują pojedyncze procenty, a nie 15%.

**Co to oznacza praktycznie u ciebie:**
- Twój scenariusz **nie jest zależny od CPU** — gra renderuje się na PS5, a twój PC robi skalowanie i generowanie klatek **na GPU**. To znaczy, że jesteś blisko „najlepszego przypadku”, czyli ~1–2%.
- Jeśli przejdziesz z Windows 10 przez aktualizację w miejscu, Integralność pamięci będzie prawdopodobnie **wyłączona** (Microsoft nie włącza jej przy aktualizacjach). W takim razie **nic nie rób** — zostaw jak jest.
- Jeśli jest włączona i wszystko działa płynnie — **zostaw włączoną.** 1–2% nie jest warte obniżania ochrony.
- Microsoft od października/listopada 2026 rozszerza włączanie Integralności pamięci na kolejne komputery (KB5127936, KB5132061), więc może ci się włączyć sama. Jeśli dokładnie wtedy zauważysz spadek — już wiesz, gdzie szukać.

**Przy okazji ważne:** jeśli nie używasz WSL ani maszyn wirtualnych, wyłącz **SVM Mode** w BIOS-ie (A4) i funkcję **Platforma maszyny wirtualnej** w `Włącz lub wyłącz funkcje systemu Windows`. Wirtualizacja włączona „na zapas” podnosi koszt VBS, nic nie dając.

## C6. Mniejsze ustawienia, które naprawdę coś robią

| Co | Gdzie | Dlaczego |
|---|---|---|
| **Szybkie uruchamianie — wyłącz** | `Opcje zasilania` → `Wybierz działanie przycisków zasilania` → `Zmień ustawienia obecnie niedostępne` → odznacz **Włącz szybkie uruchamianie** | Przy nim Windows nigdy się porządnie nie wyłącza — stąd dziwne błędy sterowników i narastające problemy. Masz SSD, start i tak jest szybki |
| **Hibernacja — wyłącz** | PowerShell (admin): `powercfg /h off` | Zwalnia **~13 GB** na C: (plik hibernacji ≈ 40% RAM-u, a masz 32 GB). Wyłącza też szybkie uruchamianie, czyli dwa ptaszki za jednym zamachem |
| **Zwiększ precyzję wskaźnika — wyłącz** | `Ustawienia` → `Urządzenia Bluetooth` → `Mysz` → `Dodatkowe ustawienia myszy` → `Opcje wskaźnika` → odznacz | Akceleracja myszy psuje celowanie. Nie dotyczy pada, ale do gry na PC tak |
| **Efekty wizualne** | `sysdm.cpl` → `Zaawansowane` → `Wydajność` → **Dostosuj: wydajność**, ale zostaw zaznaczone *Wygładź czcionki ekranowe* i *Pokaż miniatury* | Mniej animacji = responsywniejszy pulpit |
| **Dynamiczna częstotliwość odświeżania — wyłącz** | `Ustawienia` → `System` → `Ekran` → `Zaawansowane` | Przy stałym 240 Hz niepotrzebna, a czasem powoduje migotanie |
| **Powiadomienia / Asystent koncentracji uwagi** | `Ustawienia` → `System` → `Powiadomienia` → włącz **Nie przeszkadzać** przy grach pełnoekranowych | Powiadomienie w trakcie = przycinka |
| **Aplikacje w tle** | `Ustawienia` → `Aplikacje` → `Zainstalowane aplikacje` → trzy kropki przy aplikacji → `Opcje zaawansowane` → *Uprawnienia aplikacji w tle* → **Nigdy** | Zrób to dla aplikacji Store, których nie używasz |
| **Autostart** | `Ctrl+Shift+Esc` → **Uruchamianie** | Zostaw: antywirus, audio, NZXT CAM, MSI Afterburner. Wyłącz: Steam, Discord, Spotify, OneDrive, Epic, Adobe, Teams |
| **Plik wymiany** | `sysdm.cpl` → `Zaawansowane` → `Wydajność` → `Zaawansowane` → `Pamięć wirtualna` | **Zostaw „Zarządzany przez system”.** Nie wyłączaj — część gier i sterowników tego wymaga, nawet przy 32 GB |
| **Dźwięk** | `mmsys.cpl` → urządzenie → `Zaawansowane` → **24-bit, 48000 Hz**, odznacz ulepszenia dźwięku | Mniejsze opóźnienie audio, zgodność z dźwiękiem z grabbera |

---

# CZĘŚĆ D — czyszczenie (najlepsze narzędzia, po kolei)

Punkt przywracania — i ruszamy. Kolejność ma znaczenie: od najbezpieczniejszego i najskuteczniejszego do najbardziej niszowego.

## D1. Oczyszczanie dysku z plikami systemowymi

```
Start → cleanmgr → wybierz C: → OK → przycisk "Oczyść pliki systemowe" → znów C:
```

Zaznacz:
- ✅ **Oczyszczanie usługi Windows Update** ← tu siedzi najwięcej, często 5–20 GB
- ✅ **Pliki optymalizacji dostarczania** (cache aktualizacji dla innych komputerów w sieci)
- ✅ Pliki tymczasowe, Kosz, Miniatury, Raporty o błędach
- ✅ **Poprzednie instalacje systemu Windows** / `Windows.old` ← **tylko jeśli minęło ponad 10 dni od aktualizacji do Win11** i jesteś pewien, że nie chcesz wracać. To często **20–30 GB**
- ❌ **nie** zaznaczaj „Pobrane” (to twój folder Pobrane, nie cache)

Typowy odzysk: **10–40 GB**.

## D2. DISM — magazyn komponentów (WinSxS)

PowerShell **jako administrator**:

```powershell
# 1. Najpierw sprawdź, czy w ogóle jest co czyścić (nic nie zmienia)
Dism /Online /Cleanup-Image /AnalyzeComponentStore

# 2. Jeśli raport mówi "Zalecane oczyszczanie magazyny komponentów: Tak" - wykonaj
Dism /Online /Cleanup-Image /StartComponentCleanup
```

To oficjalna metoda Microsoftu. Usuwa stare wersje komponentów natychmiast, bez 30-dniowego okresu łaski.

> ⚠️ **`/ResetBase` — ostrożnie.** Dodanie `/ResetBase` usuwa **wszystkie** zastąpione wersje komponentów i daje więcej miejsca, ale **odbiera możliwość odinstalowania zainstalowanych aktualizacji**. Microsoft pozycjonuje to jako operację „fabryczną”, nie rutynową. Użyj tylko jeśli naprawdę walczysz o miejsce na C: i wiesz, że nie będziesz cofać aktualizacji.

> ⛔ **Nigdy nie usuwaj plików z `C:\Windows\WinSxS` ręcznie.** Microsoft ostrzega wprost: Windows może przestać się uruchamiać albo aktualizować.

## D3. Sprawdzenie i naprawa plików systemowych

PowerShell jako administrator, w tej kolejności:
```powershell
sfc /scannow
Dism /Online /Cleanup-Image /RestoreHealth
sfc /scannow
```
Drugie `sfc` po `RestoreHealth` naprawia to, czego pierwsze nie mogło (bo brakowało mu zdrowych źródeł).

## D4. Znajdź, co zajmuje miejsce na HDD 6 TB

Masz 6 TB — tam zawsze są zapomniane rzeczy. Ale **nie zgaduj**, zobacz:

- **WizTree** — najszybszy analizator na Windowsie (czyta bezpośrednio tablicę MFT dysku NTFS, skanuje 6 TB w kilka sekund). Darmowy do użytku domowego. Oficjalnie: https://wiztreefree.com/
- albo **TreeSize Free** — https://www.jam-software.com/treesize-free — wolniejszy, ale wygodniejszy widok drzewa
- albo **WinDirStat** / **QDirStat** — darmowe, otwarte

Czego szukać: stare instalatory gier, foldery `Shader Cache`, nagrania ShadowPlay/OBS, kopie zapasowe telefonu, duplikaty bibliotek Steam.

## D5. Dyski — obsługa dopasowana do typu

| Dysk | Co zrobić | Czego NIE robić |
|---|---|---|
| **C: (SSD/NVMe)** | Zostaw **„Optymalizuj” w `dfrgui`** — Windows wysyła TRIM, nie defragmentuje. Trzymaj **minimum 15% wolnego** — pełny SSD gwałtownie zwalnia | ❌ nie defragmentuj SSD · ❌ nie wyłączaj TRIM · ❌ nie wyłączaj SysMain |
| **D: (HDD 6 TB)** | **Defragmentuj** (`dfrgui` → D: → Optymalizuj) — tu ma to realny sens. Ustaw harmonogram co miesiąc | ❌ nie wyłączaj zasypiania na *nigdy* po stronie dysku? — przeciwnie, **ustaw „nigdy”** (C1), bo wybudzanie talerzy to zawieszki |

**Indeksowanie wyszukiwania na HDD:** jeśli D: to głównie gry i filmy, wyłącz dla niego indeksowanie — `Ten komputer` → prawy klik na D: → `Właściwości` → odznacz **„Zezwalaj na indeksowanie zawartości plików…”**. Mniej ruchu głowicy w tle. (Na C: **zostaw włączone** — wyszukiwanie w menu Start z niego korzysta.)

**Sprawdź stan dysków:** `diagnoza.ps1` sekcja 6 pokazuje SMART, albo **CrystalDiskInfo** (https://crystalmark.info/). Na HDD patrz na *Reallocated Sectors* i *Current Pending Sector* — cokolwiek powyżej 0 i rosnące = rób kopię danych.

## D6. Chris Titus WinUtil

Oficjalnie — **wyłącznie** konto `ChrisTitusTech`:
- https://github.com/ChrisTitusTech/winutil
- https://winutil.christitus.com/
- licencja MIT

PowerShell jako administrator:
```powershell
irm "https://christitus.com/win" | iex
```

| Zakładka | Co zrobić |
|---|---|
| **Tweaks** | preset **Standard** → **Run Tweaks**. (Sam robi punkt przywracania, ale zrób swój wcześniej) |
| **Install** | wygodna instalacja z oficjalnych źródeł: 7-Zip, VLC, OBS, HWiNFO, MSI Afterburner, CrystalDiskInfo |
| **Updates** | zostaw **Default (Out of Box)** |

**Czego nie ruszać:** nic, co wyłącza Defendera, zaporę ani Windows Update. Nie usuwaj Edge'a (psuje aktualizacje). Nie usuwaj Microsoft Store.

Co z presetu Standard faktycznie pomaga: wyłączenie telemetrii, Cortany, reklam i podpowiedzi w menu Start, zbędnych zadań zaplanowanych, Game DVR.

## D7. Aktualizacja wszystkich programów jedną komendą

Windows ma wbudowany menedżer pakietów — nie potrzebujesz żadnego „updatera”:
```powershell
winget upgrade --all --include-unknown
```

---

# CZĘŚĆ E — QD-OLED: jak nie spalić monitora

To nie jest optymalizacja wydajności, ale **najcenniejsza rzecz na tej liście w złotówkach.** QD-OLED jest podatny na wypalenie, a ty planujesz godziny z tym samym HUD-em GTA 6 w tym samym miejscu ekranu — mapa w lewym dolnym, minimapa, pasek zdrowia. Dokładnie taki scenariusz wypala panele.

## E1. W menu monitora (OSD) — MSI OLED Care 2.0

MSI MAG 271QP ma wbudowaną ochronę. Włącz **wszystko**:

| Opcja | Ustaw | Co robi |
|---|---|---|
| **Pixel Shift** | **Normal** | Przesuwa obraz o kilka pikseli w regularnych odstępach |
| **Static Screen Detection** | **Włączone** | Przygasza obraz, gdy wykryje nieruchomy obraz na dłużej |
| **Taskbar Detection** | **poziom 3 (−20%)** | Przygasza obszar paska zadań — najczęstsze miejsce wypalenia |
| **Boundary Detection** | **poziom 3** | Przygasza krawędzie okien, czarne pasy, pionowe linie |
| **Panel Protect / Protect Notice** | **Usage 16 hrs** | Monit o uruchomienie odświeżania pikseli po 16 h pracy (opcja „Auto” pyta co 4 h i szybko się uprzykrza) |

**Uruchamiaj Panel Protect**, kiedy monitor o to poprosi — nie odkładaj. Trwa kilka minut i trzeba w tym czasie nie używać monitora.

> Po aktualizacji firmware'u monitora **wróć do OSD i sprawdź, czy te opcje nadal są włączone** — MSI sam o tym ostrzega, bo aktualizacja potrafi je zresetować.

## E2. W Windowsie

| Co | Jak | Dlaczego |
|---|---|---|
| **Ukryj pasek zadań** | `Ustawienia` → `Personalizacja` → `Pasek zadań` → `Zachowania paska zadań` → **Automatycznie ukrywaj** | Pasek zadań to element #1 wypalany na OLED. MSI zaleca to wprost |
| **Tryb ciemny** | `Ustawienia` → `Personalizacja` → `Kolory` → **Ciemny** | Mniej świecących pikseli = mniejsze zużycie |
| **Wygaszacz / wyłączanie ekranu** | `Ustawienia` → `System` → `Zasilanie` → *Wyłącz ekran po* → **5 minut** | Najskuteczniejsza ochrona, jaka istnieje |
| **Tapeta** | zmieniająca się pokazówka, nie jedna statyczna | — |
| **Jasność SDR na pulpicie** | **nie trzymaj na 100%** — 30–50% wystarcza w pomieszczeniu | Jasność wprost przekłada się na szybkość degradacji |
| **Ikony na pulpicie** | mniej, albo ukryj (prawy klik na pulpicie → `Widok` → odznacz *Pokaż ikony pulpitu*) | Statyczne elementy |
| **Nie zostawiaj zatrzymanej gry/filmu na godziny** | — | Zatrzymany obraz z HUD-em to najgorszy możliwy przypadek |

**Dodatkowo pod twój scenariusz:** jeśli zostawiasz podgląd z grabbera z zatrzymaną grą (menu pauzy GTA 6 z nieruchomym HUD-em) — **zamykaj go albo przełączaj monitor**. Menu pauzy wyświetlane godzinami to realne ryzyko.

## E3. Czego się nie bać

Normalne granie z włączoną ochroną OLED Care i wyłączaniem ekranu po 5 minutach bezczynności jest **bezpieczne**. Panele QD-OLED z 2024+ są znacznie trwalsze niż pierwsze generacje, a monitor ma gwarancję obejmującą wypalenie (sprawdź warunki u sprzedawcy — MSI zwykle daje 3 lata na burn-in). Nie chodzi o paranoję, tylko o włączenie pięciu opcji i ukrycie paska zadań.

---

# CZĘŚĆ F — konkretnie pod przechwytywanie + generowanie klatek

To, co powyżej, dotyczy całego komputera. Te rzeczy są specyficzne dla twojego scenariusza:

| Co | Dlaczego |
|---|---|
| **Zostaw GPU zapas — celuj w 80–90% obciążenia, nie 99%** | Generowanie klatek z nasyconego GPU to narastające opóźnienie i szarpanie. Jeśli siedzisz na 99% → zmniejsz mnożnik z 4X na 2X albo Flow scale na 50% |
| **Zamknij wszystko, co zajmuje urządzenie wideo** | Discord, Teams, Skype, aplikacja Kamera, OBS — potrafią przejąć grabber i program go „nie widzi” |
| **Wyłącz wszystkie nakładki** | NVIDIA (ALT+Z), Discord, Steam, MSI Afterburner/RTSS, NZXT CAM. Każda z nich wstrzykuje się w potok wyświetlania i koliduje z programem generującym klatki. RTSS w Veyrze był testowany tylko na RTX 5070 |
| **Daj programowi wysoki priorytet** | Menedżer zadań → `Szczegóły` → prawy klik na procesie → `Ustaw priorytet` → **Wysoki**. Nie *Czas rzeczywisty* — to potrafi zawiesić system |
| **Przypisz program do dedykowanej karty** | `Ustawienia` → `System` → `Ekran` → `Grafika` → dodaj plik .exe → **Wysoka wydajność** |
| **Trzymaj program i cache shaderów na SSD**, nie na HDD D: | Czas wczytywania i przycinki |
| **Monitor główny = ten, na którym gra idzie na pełnym ekranie** | Okno przeniesione na drugi monitor dostaje inną ścieżkę wyświetlania i więcej opóźnienia |
| **Nie włączaj jednocześnie generowania klatek w dwóch programach** | Veyra + Lossless Scaling + NVIDIA Smooth Motion jednocześnie = kaskada opóźnień i artefaktów. **Jeden program, jedno generowanie** |
| **Plik wymiany na SSD, nie na HDD** | Przy 8 GB VRAM Windows czasem zrzuca tekstury do RAM i dalej na dysk |

---

# CZĘŚĆ G — jak sprawdzić, że to w ogóle pomogło

Bez pomiaru „optymalizacja” to wiara. Zasada: **jedna zmiana → pomiar → następna zmiana.**

| Narzędzie | Do czego | Skąd |
|---|---|---|
| **CapFrameX** | Najlepsze darmowe do czasów klatek. Pokazuje 1% i 0,1% najniższych — tam widać mikroprzycinki, których średni FPS nie pokazuje | https://www.capframex.com/ |
| **HWiNFO64** | Temperatury (CPU, GPU, **GPU Hot Spot**, **GPU Memory Junction**), taktowania, pobór, throttling | https://www.hwinfo.com/ |
| **OCCT** | Test stabilności CPU i RAM po Curve Optimizer / XMP | https://www.ocbase.com/ |
| **CoreCycler** | Test stabilności pojedynczych rdzeni — wyłapuje to, czego Cinebench nie wyłapie | https://github.com/sp00n/corecycler |
| **3DMark Time Spy Stress Test** | Stabilność GPU po undervolcie (20 pętli, wynik ma być >97%) | Steam |
| **Cinebench R23** | Punkt odniesienia dla CPU przed/po PBO | Microsoft Store |

**Na co patrzeć, a nie na średni FPS:**
- **1% najniższych** — jeśli rośnie, grasz płynniej, nawet gdy średnia stoi
- **czas klatki (frame time)** — ma być płaską linią, nie piłą
- **temperatura GPU Memory Junction** — poniżej 95 °C
- **temperatura CPU** — pod obciążeniem do 85 °C jest OK dla Ryzena; 95 °C to limit, przy którym zaczyna ograniczać boost

---

# CZĘŚĆ H — czego NIE robić (i dlaczego, skoro wszyscy to polecają)

Przeszukałem to szeroko i poniższe rzeczy albo nie działają, albo szkodzą. Każda ma uzasadnienie.

| Mit | Dlaczego nie |
|---|---|
| **Czyszczenie rejestru** (CCleaner, Wise Registry Cleaner) | Nie daje mierzalnego zysku na żadnym współczesnym Windowsie. Rejestr jest wczytywany do pamięci, jego rozmiar nie wpływa na FPS. Ryzyko: usunięcie wpisu potrzebnego programowi |
| **CCleaner** | Poza bezużytecznym czyszczeniem rejestru: w 2017 r. instalatory CCleanera rozsyłały złośliwe oprogramowanie. `cleanmgr` + DISM robią to samo bezpieczniej |
| **Tweaki timerów w `bcdedit`** (`useplatformclock`, `disabledynamictick`, `tscsyncpolicy`) | To relikt Windows 7. Na Windows 10/11 domyślne ustawienia są optymalne, a nadpisania **powodują** przycinki. Jeśli ktoś ci to wcześniej ustawił — `diagnoza.ps1` sekcja 11 to pokaże |
| **Wyłączanie SysMain / Superfetch** | Na SSD nieszkodliwe, ale bez zysku. **Na HDD szkodzi** — a ty masz HDD jako D: |
| **Wyłączanie pliku wymiany** | Część gier i sterowników go wymaga niezależnie od ilości RAM. Objaw: losowe „out of memory” przy 32 GB wolnego |
| **„Ultimate Performance” / „Bitsum Highest Performance”** | Na Ryzenie nic nie daje w grach, podnosi pobór i temperatury na bezczynności |
| **Wyłączanie SMT / rdzeni** | Tracisz wydajność w wielowątkowości, a generowanie klatek + przechwytywanie + Windows to kilka wątków jednocześnie |
| **Ręczne przypisywanie rdzeni (CPU affinity)** dla gier | Łamie działanie CPPC Preferred Cores — Windows przestaje umieszczać pracę na najszybszych rdzeniach. Efekt zwykle odwrotny do zamierzonego |
| **Tweaki MSI mode / Interrupt affinity w rejestrze** | Marginalne zyski w najlepszym razie, w najgorszym niestabilne urządzenia USB — czyli dokładnie twój grabber |
| **„RAM cleanery” / „Memory optimizery”** | Wypychają dane z pamięci podręcznej, którą Windows właśnie zbudował. Efekt: krótkoterminowo „więcej wolnego RAM”, długoterminowo wolniejszy system |
| **„Windows 11 Lite”, Ghost Spectre, Tiny11, AtlasOS, ReviOS** | Usunięte komponenty bezpieczeństwa, zablokowane aktualizacje, brak wsparcia. Na tym nie uruchomisz części gier i nie dostaniesz łatek |
| **Skrypty „debloat”, które usuwają Microsoft Store / Defendera / Windows Update** | Niemożliwe do cofnięcia bez reinstalacji. Store jest potrzebny m.in. do aplikacji HDR Calibration |
| **Driver Booster, DriverPack Solution, Snappy Driver** | Instalują nieodpowiednie sterowniki. Sterowniki bierz od AMD, NVIDII i Gigabyte |
| **Overclock GPU „na maksa”** (Core +150, Power Limit 112%) | Na 3070 Ti z GDDR6X daje 1–2% FPS za 50 W i 8 °C więcej. **Undervolt daje więcej niż overclock** |
| **Wyłączanie Global C-states** w BIOS | Blokuje boost i Curve Optimizer. Jeśli to „naprawia” twój undervolt — undervolt jest za agresywny |
| **„FPS Unlocker” / „GTA 6 PC” / „PS5 60FPS Patch”** | GTA 6 nie ma wersji PC (listopad 2026). Łatki do PS5 nie instalują się z pliku .exe na Windowsie. To złośliwe oprogramowanie |
| **Wyłączanie Defendera, zapory, aktualizacji** | Nasza żelazna zasada. Nowoczesny Defender kosztuje w grach pojedyncze procenty, a jest jedyną ochroną, jaką masz |

---

# Kolejność robienia — plan na jeden wieczór

**Wieczór 1 (BIOS, ~1 h):**
1. Punkt przywracania + zapis profilu BIOS
2. XMP → Profile1, sprawdź FCLK = połowa pamięci → test `mdsched` lub 30 min gry
3. CSM Disabled, Above 4G Decoding, Re-Size BAR Auto → sprawdź w Panelu NVIDII
4. CPPC + CPPC Preferred Cores → Enabled, Power Supply Idle Control → Typical Current Idle, ErP → Disabled
5. Krzywa wentylatorów (F6)

**Wieczór 2 (CPU i GPU, ~1,5 h):**
6. Sterownik chipsetu AMD, potem sterownik NVIDII (czysta instalacja)
7. Curve Optimizer −15 → OCCT 30 min + CoreCycler → jeśli OK, próbuj −20
8. MSI Afterburner: undervolt 900 mV, pamięć +500 → Time Spy Stress Test
9. Cinebench R23 i zapisz wynik jako punkt odniesienia

**Wieczór 3 (Windows i czyszczenie, ~1 h):**
10. Plan Zrównoważony, dysk twardy „nigdy nie wyłączaj”
11. Tryb gry on, Game DVR off, widżety off, autostart przejrzany
12. Szybkie uruchamianie off, `powercfg /h off`, efekty wizualne na wydajność
13. `cleanmgr` z plikami systemowymi → DISM AnalyzeComponentStore → StartComponentCleanup
14. WizTree na D:, defragmentacja D:, indeksowanie D: off
15. WinUtil preset Standard
16. OLED Care w monitorze + ukrycie paska zadań + wyłączanie ekranu po 5 min

**Wieczór 4 (A/B testy, ~1 h):**
17. HAGS on vs off — 20 min gry każde, CapFrameX
18. Optymalizacje dla gier okienkowych on vs off — to samo
19. Zostaw konfigurację z równiejszym czasem klatek

---

## Źródła

**CPU / BIOS**
- [Przewodnik Curve Optimizer 2026 — start od −15 dla Ryzen 5/7, pułapka z C-states, OCCT + CoreCycler](https://www.xilly.net/blog/ryzen-curve-optimizer-undervolt-guide)
- [Raporty użytkowników 5700X: crash przy −25, stabilność przy −23](https://linustechtips.com/topic/1640010-ryzen-7-5700x-voltage-spikes-with-pbo-and-undervolting/)
- [Zakres −15 do −30, przykłady PPT/TDC/EDC na B550](https://linustechtips.com/topic/1466105-best-pbo-setting-for-ryzen-7-5700x/)
- [AMD zaleca plan Zrównoważony; „Wysoka wydajność” zmienia głównie bezczynność](https://www.xda-developers.com/your-high-performance-power-plan-might-be-hurting-your-cpus-gaming-performance/)
- [Dlaczego Balanced, core parking i CPPC2](https://windowsforum.com/news/amd-ryzen-dual-ccd-x3d-gaming-why-windows-balanced-power-plan-matters.449796/)
- [CPPC i CPPC Preferred Cores — zalecenie włączenia](https://forums.guru3d.com/threads/cppc-preferred-cores.448289/)

**GPU**
- [Gigabyte — oficjalna instrukcja Resizable BAR (Above 4G Decoding + Re-Size BAR Auto)](https://www.gigabyte.com/WebPage/785/NVIDIA_resizable_bar.html)
- [NVIDIA — narzędzie aktualizacji vBIOS dla ReBAR na RTX 30](https://nvidia.custhelp.com/app/answers/detail/a_id/5165/)
- [Undervolt 3070 Ti: 0,95 V → ~240 W, <80 °C przy zegarach fabrycznych](https://linustechtips.com/topic/1457075-rtx-3070ti-fe-concerns/)
- [Undervolt 3070 Ti: 0,85 V → 289 W/76 °C na 204 W/67 °C](https://linustechtips.com/topic/1392392-undervolting-opinions-rtx-3070-ti/)
- [Display Driver Uninstaller — oficjalne źródło](https://www.wagnardsoft.com/ddu)

**Windows**
- [HAGS rezerwuje do 1 GB VRAM — ryzyko na kartach 8 GB; HAGS i OBS wymagają testu](https://windowsforum.com/news/windows-11-gaming-boost-game-mode-hags-vrr-windowed-optimizations.401434/)
- [Optymalizacje dla gier okienkowych — DX10/DX11, flip model; sprzeczne raporty o przycinkach od 24H2](https://fpstweak.com/blog/optimizations-for-windowed-games-windows-11)
- [Integralność pamięci — nowe pomiary ~1,7–1,9%, rola MBEC](https://www.xda-developers.com/windows-11-has-enabled-memory-integrity-but-gamers-shouldnt-worry-that-much/)
- [Integralność pamięci na Ryzen 7 5800X w 720p: −6% FPS, −8% czasy klatek](https://www.darkflash.com/article/memory-integrity-gaming)
- [Tom's Hardware — skąd się wzięło „do 15%” i jak MBEC to zmniejsza](https://www.tomshardware.com/news/windows-11-gaming-benchmarks-performance-vbs-hvci-security)
- [Rozszerzanie Integralności pamięci: KB5127936 (28.10.2026) i KB5132061](https://windowsforum.com/news/windows-11-kb5132061-expands-memory-integrity-gaming-performance-and-security-trade-offs.451887/)

**Czyszczenie**
- [Microsoft — oficjalne czyszczenie WinSxS, ostrzeżenie o `/ResetBase` i o ręcznym usuwaniu plików](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder?view=windows-11)
- [Chris Titus WinUtil — oficjalne repozytorium (MIT)](https://github.com/ChrisTitusTech/winutil) · [dokumentacja](https://winutil.christitus.com/)
- [TreeSize Free — strona producenta](https://www.jam-software.com/treesize-free)

**Monitor**
- [MSI — jak używać monitorów OLED i zapobiegać wypaleniu (ukrycie paska zadań, Boundary Detection 3, Panel Protect 16 h)](https://www.msi.com/blog/how-to-use-msi-oled-monitors-for-productivity-essential-tips-to-prevent-burn-In)
- [MSI MAG 271QP QD-OLED — strona produktu (OLED Care 2.0)](https://www.msi.com/Monitor/MAG-271QP-QD-OLED-X24)
- [Instrukcja MAG 271QP — opisy Pixel Shift, Static Screen / Taskbar / Boundary Detection](https://manuals.plus/m/71da76f51053e3c1319b0cf8ea40729a1b05d4737bbb4945c4fe494fb673c46c)
