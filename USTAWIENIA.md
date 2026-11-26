# USTAWIENIA — GTA 6 z PS5 na PC przez kartę przechwytującą + generowanie klatek

Instrukcja krok po kroku dla konfiguracji:
**PS5 (GTA 6, 30 FPS) → grabber HDMI USB 3.0 → PC (Ryzen 7 5700X, RTX 3070 Ti 8 GB) → monitor MSI MAG 271QP QD-OLED 1440p 240 Hz**

Cel: **60–120 FPS na ekranie, priorytet: małe opóźnienie.**

---

## ZASADA NR 1 — zanim cokolwiek zmienisz

**Zrób punkt przywracania systemu.** Każdy rozdział, który zmienia coś w Windowsie, zaczyna się od tego.

1. Wpisz w Menu Start: `Utwórz punkt przywracania` → Enter
2. Zakładka **Ochrona systemu** → zaznacz dysk `C:` → **Konfiguruj** → *Włącz ochronę systemu* → maks. użycie 5–10% → OK
3. Przycisk **Utwórz…** → nazwa np. `przed GTA6 setup 2026-11-26` → **Utwórz**
4. Poczekaj na komunikat „Punkt przywracania został utworzony”

Jeśli coś pójdzie nie tak: ten sam ekran → **Przywracanie systemu…** → wybierz punkt.

### Czego NIE robimy (nigdy, w żadnym kroku)
- ❌ Nie wyłączamy Microsoft Defender
- ❌ Nie wyłączamy zapory (firewall)
- ❌ Nie wyłączamy ani nie blokujemy Windows Update
- ❌ Nie dodajemy wyjątków w Defenderze dla instalatorów
- ❌ Nie instalujemy „boosterów”, „optymalizatorów” ani paczek „GTA 6 PC”

> Uwaga: wiki Veyry w kilku miejscach radzi wyłączyć Windows Security. **Nie rób tego.** Zamiast tego sprawdź sumę kontrolną SHA256 pliku (opisane niżej) — to osiąga ten sam cel (pewność, że plik jest oryginalny) bez obniżania ochrony.

---

## 1. Jak to w ogóle działa (i gdzie siedzi opóźnienie)

```
GTA 6 na PS5   →  HDMI  →  grabber  →  USB 3.0  →  PC: program  →  monitor
   30 FPS          60 Hz    1080p60    ~10-16 ms   odszumianie     1440p
                 (klatki                           + skalowanie    60-120 FPS
                 zdublowane!)                      + generowanie
```

**Pad zostaje podłączony do PS5** — przez Bluetooth albo kabel USB do konsoli.
To najważniejsza decyzja dla opóźnienia: sterowanie **nie przechodzi** przez PC, więc PC dodaje opóźnienie tylko do **obrazu**, nie do reakcji gry.

### Problem zdublowanych klatek — przeczytaj to, bo od tego wszystko zależy

GTA 6 na PS5 renderuje **30 klatek na sekundę**, ale HDMI zawsze wysyła sygnał 60 Hz.
Konsola po prostu **wysyła każdą klatkę dwa razy**:

```
Co faktycznie leci kablem:   A  A  B  B  C  C  D  D   (60 klatek/s)
Co jest unikalne:             A     B     C     D     (30 klatek/s)
```

Jeśli program do generowania klatek tego nie wie, próbuje „domyślać się ruchu” między **A i A** (czyli między dwiema identycznymi klatkami) — i wychodzi szarpanie, nierówne tempo, migotanie. To najczęstszy powód, dla którego ludziom „nie działa” generowanie klatek z konsoli.

**Rozwiązanie:** program musi wyrzucić duplikaty (tryb „60→30”) i dopiero z czystych 30 unikalnych klatek generować 60 lub 120.

To jest dokładnie powód, dla którego poniżej polecam **Veyra NR** — ona ma to wbudowane.

---

## 2. PS5 — ustawienia konsoli

### 2a. Wyłącz HDCP (bez tego grabber pokaże czarny ekran)

**Zrób to, gdy PS5 jest podłączona BEZPOŚREDNIO do telewizora lub monitora** — przez grabber się nie da, bo menu nie będzie widoczne.

`Ustawienia` → `System` → `HDMI` → **Włącz HDCP** → **wyłącz**

Konsola się zrestartuje.

> Skutek uboczny: aplikacje wideo (Netflix, Disney+, HBO) przestaną działać na PS5, dopóki HDCP jest wyłączone. Gry działają normalnie. Jak chcesz pooglądać — włącz z powrotem.

### 2b. Wyjście wideo

`Ustawienia` → `Ekran i wideo` → `Wyjście wideo`:

| Opcja | Ustaw na | Dlaczego |
|---|---|---|
| **Rozdzielczość** | **1080p** (ręcznie, nie „Automatycznie”) | Tani grabber na MS2131 przechwytuje maksymalnie 1080p60. Przy 1440p/4K dostaniesz czarny ekran albo 30 Hz. |
| **Głębia kolorów** | Automatycznie | — |
| **Wyjście RGB** | **Ograniczony** (Limited) | Grabbery UVC pracują w zakresie ograniczonym (16–235). Przy „Pełny” kolory będą wyprane / czernie szare. |
| **Włącz 120 Hz** | nie ma znaczenia | GTA 6 i tak daje 30 FPS |
| **ALLM** | Włączone | — |

### 2c. HDR

`Ustawienia` → `Ekran i wideo` → `Wyjście wideo` → **HDR** → **Wyłączone**

**Na start zostaw HDR wyłączone.** Powody:
- tanie grabbery na MS2131 często przekazują metadane HDR błędnie → obraz wychodzi czerwonawy/spłaszczony
- HDR wymaga formatu 10-bitowego (P010), który zajmuje więcej pasma USB i dodaje opóźnienie
- przy 8 GB VRAM na 3070 Ti każdy dodatkowy koszt boli

HDR na QD-OLED jest piękne, więc jak wszystko inne już działa stabilnie — możesz spróbować włączyć (patrz rozdział 8), ale traktuj to jako bonus, nie jako punkt wyjścia.

### 2d. Pad

Nic nie zmieniaj — **pad zostaje sparowany z PS5**. Nie podłączaj go do PC.

Dźwięk: najlepiej **słuchawki w gniazdo pada** (`Ustawienia` → `Dźwięk` → `Wyjście audio` → Słuchawki). Dźwięk nie przechodzi wtedy przez PC i nie ma rozsynchronizowania z obrazem. Alternatywa: dźwięk z grabbera przez PC — wtedy obraz i dźwięk są zsynchronizowane ze sobą, ale oba opóźnione.

---

## 3. Kable i podłączenie

```
  PS5  ──HDMI──►  GRABBER (wejście HDMI IN)
                      │
                      └──USB-A──►  TYLNY port USB 3.x płyty B550 (niebieski)

  RTX 3070 Ti ──DisplayPort──►  MSI MAG 271QP (główny, 240 Hz)
  RTX 3070 Ti ──DisplayPort──►  Gigabyte G27Q2  (drugi, 200 Hz)
```

Zasady:
1. **Grabber wtykaj bezpośrednio w tył płyty głównej.** Nie w przedni panel obudowy, nie w hub, nie w przedłużacz. Port USB 3.x na B550 Gaming X V2 jest niebieski (5 Gb/s) — to wystarczy dla 1080p60.
2. **Monitory podłącz przez DisplayPort**, nie HDMI — HDMI na 3070 Ti to 2.1, ale DP jest pewniejsze dla 1440p 240 Hz z G-Sync.
3. Kabel HDMI z PS5 do grabbera: wystarczy ten z zestawu PS5 (High Speed / Premium). Nie kupuj drogiego.
4. Jeśli grabber ma wyjście **HDMI OUT (loop/pętla)** — nie musisz go używać. Pamiętaj tylko, że tanie MS2131 przepuszczają przez pętlę maks. 4K **30** Hz, więc nie nadaje się do podglądu na telewizorze 120 Hz.

### Sprawdzenie, że grabber działa
1. Włóż grabber do USB → Windows sam zainstaluje sterownik (urządzenie UVC, bez sterowników producenta)
2. Włącz PS5
3. Otwórz wbudowaną aplikację **Kamera** w Windows → przełącz źródło na „USB Video” / „MACROSILICON”
4. Powinieneś zobaczyć obraz z PS5

Jeśli czarny ekran → HDCP nie jest wyłączone (krok 2a) albo rozdzielczość PS5 nie jest 1080p (krok 2b).
Aplikacja Kamera to tylko test — do gry służy program z rozdziału 4.

---

## 4. WYBRANY PROGRAM: Veyra NR

**To jest rekomendacja.** Uzasadnienie i porównanie z Lossless Scaling — w pliku `PODSUMOWANIE` / w odpowiedzi w czacie. Krótko: Veyra jest jedynym programem, który ma wbudowane **usuwanie zdublowanych klatek (60→30)**, czyli rozwiązuje główny problem opisany w rozdziale 1. Jest darmowa (GPL-3.0). Wymaga **Windows 11** — dlatego najpierw zrób `BIOS_WIN11.md`.

Jeśli chcesz zostać na Windows 10 → przeskocz do **rozdziału 5 (Lossless Scaling)**.

### 4a. Instalacja — bezpiecznie

**Jedyne oficjalne źródło:**
https://github.com/Likely7/Veyra-NRVideo/releases/latest

1. Pobierz paczkę **dla NVIDII** (plik z „NVIDIA” w nazwie — Setup .exe albo portable .zip)
2. Pobierz też plik **`SHA256SUMS.txt`** z tej samej strony
3. **Sprawdź sumę kontrolną** (to zastępuje wyłączanie antywirusa — nie wyłączaj Defendera):
   ```powershell
   Get-FileHash .\nazwa_pobranego_pliku.exe -Algorithm SHA256
   ```
   Porównaj wynik z linią dla tego pliku w `SHA256SUMS.txt`. **Zgadza się → plik jest oryginalny. Nie zgadza się → usuń i pobierz ponownie.**
4. Dopiero teraz **punkt przywracania** (rozdział „ZASADA NR 1”) i instalacja

> Czego się spodziewać: instalatory Veyry **nie są podpisane cyfrowo** (Authenticode), więc SmartScreen pokaże ostrzeżenie „Nieznany wydawca”. To normalne dla małego projektu open-source — ale dlatego suma SHA256 jest obowiązkowa. Jeśli wolisz nic nie instalować, weź wersję **portable .zip** i rozpakuj do osobnego folderu.
>
> Drugie ostrzeżenie: w README projektu jest reklama tokena kryptowalutowego „społeczności”. To nie ma nic wspólnego z programem. **Nic nie kupuj, nie podłączaj żadnego portfela.** Program jest darmowy i to jedyne, co cię interesuje.

### 4b. Ustawienia przechwytywania (Capture)

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| Urządzenie | USB Video / MACROSILICON (twój grabber) | — |
| Rozdzielczość | **1920 × 1080** | maksimum MS2131 przy 60 Hz |
| Klatki | **59.94** (jeśli jest; inaczej 60) | autor Veyry wprost zaleca 59.94 dla konsol |
| Format pikseli | **NV12** (jeśli brak → YUY2) | NV12 i YUY2 mają najmniejsze opóźnienie. **Nigdy MJPEG** — kompresja = dodatkowe opóźnienie i artefakty |
| Zakres | **Limited / Ograniczony** | musi się zgadzać z ustawieniem RGB na PS5 (krok 2b) |
| Krzywa koloru | **709** (SDR) | przy HDR wyłączonym na PS5 |
| Wejście audio | grabber (lub brak, jeśli słuchawki w padzie) | — |

### 4c. ⭐ Najważniejsze ustawienie: usuwanie duplikatów

Szukaj opcji o nazwie **cadence / dedup / 60→30** (w wersji 2.2.1 w interfejsie bywają chińskie etykiety `60→30`, `60→30（兼容自动去重）`, `自动去除`).

Trzy dostępne tryby:

| Tryb | Co robi | Kiedy użyć |
|---|---|---|
| **60→30** (stały) | Bierze co drugą klatkę, zsynchronizowane z pierwszą kopią każdej pary | **Zacznij od tego** — GTA 6 trzyma stabilne 30 FPS |
| **60→30 z wykrywaniem powtórzeń** | Jak wyżej, ale pomija powtórzenia gdy gra spadnie poniżej 30 | Jeśli w mieście widzisz przycinki (GTA 6 potrafi zjechać pod 30) |
| **Automatyczne wykrywanie** | Program sam rozpoznaje tempo treści | Gdy dwa poprzednie dają gorszy efekt |

**Po włączeniu tego program powinien pokazywać ~30 FPS na wejściu.** Jeśli pokazuje 60 — duplikaty nie są usuwane i generowanie klatek nie zadziała porządnie.

> Pułapka w drugą stronę: jeśli generowanie klatek działa dziwnie wolno, **sprawdź czy nie włączyłeś 60→30 do materiału, który naprawdę ma 60 FPS** (np. menu PS5). Autor Veyry wymienia to jako pierwszą rzecz do sprawdzenia.

### 4d. Skalowanie do 1440p (Super Resolution)

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| Metoda | **XeSS** | Na RTX 30 to najlepszy kompromis jakość/koszt |
| Cel | **2560 × 1440** | Rozdzielczość twojego MSI — zero skalowania przez monitor |
| Jakość | **Quality** → jeśli brakuje wydajności, **Balanced** | — |
| Dual upscaling | **WYŁĄCZONE** | Podwaja zużycie VRAM. Masz 8 GB. |
| NR (odszumianie / warstwy) | **WYŁĄCZONE na start** | Najdroższa funkcja w całym programie. Włącz dopiero gdy wszystko inne działa, i wtedy **maks. 1 warstwa w 1080p** |

> Dlaczego NR wyłączone: dokumentacja Veyry podaje, że karta **4060 8 GB** musi trzymać NR na 1080p lub nawet 900p. Twoja 3070 Ti też ma 8 GB. Najpierw zrób, żeby grało płynnie — ozdoby potem.

### 4e. ⭐ Generowanie klatek (Frame Generation)

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| Silnik | **XeSS frame generation** | Dla RTX 30 oficjalnie: *„30 series: use XESS frame generation + AMD optical flow”*. DLSS FG na serii 30 nie jest wspierane i daje najwięcej błędów obrazu. |
| Optical flow | **AMD optical flow** | Zalecane razem z XeSS. NVIDIA optical flow ma mniej migotania, ale jest droższa — spróbuj dopiero gdy masz zapas wydajności. |
| Mnożnik | **2X → 60 FPS** (start) | Autor Veyry dla przechwytywania gry 30 FPS zaleca **2X albo 4X** |
| | potem **4X → 120 FPS** | Jeśli GPU wyrabia. Cel 60–120 FPS osiągasz tu. |
| | ❌ **nie 6X** | Działa na serii 30, ale użytkownicy opisują 5X/6X jako „praktycznie bezużyteczne” |
| Limit wyjścia (output cap) | **120** | Nie ma sensu wyżej — monitor ma 240 Hz, ale generowanie z 30 FPS nie da sensownych 240 |

**Matematyka dla twojego celu:**
```
30 unikalnych klatek z PS5  ×  2X  =   60 FPS   ← bezpieczny start, najmniejsze opóźnienie
30 unikalnych klatek z PS5  ×  4X  =  120 FPS   ← cel, jeśli 3070 Ti wyrabia
```

### 4f. ⭐ Ustawienia opóźnienia

To jest sekcja, która decyduje o „priorytet: małe opóźnienie”.

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| NVIDIA Low Latency (Reflex) | **On** | **NIE „On + Enhanced”.** Dokumentacja Veyry: przy dużym obciążeniu wybieraj „On”. „Enhanced” dodaje 4–18 ms czekania na klatkę i w testach dało 8–21% mniej wygenerowanych klatek. |
| Budżet opóźnienia generowania (latency budget) | **lowest / najniższy** | Każdy stopień wyżej („+1”, „+2 klatki źródłowe”) dokłada 33 ms przy źródle 30 FPS. Dodatkowo rezerwuje 1,3–2,3 GB VRAM — a ty masz 8 GB. |
| Vsync | **wyłączone** | Masz G-Sync — monitor sam dopasuje odświeżanie. Vsync włączaj tylko jeśli widzisz rozrywanie obrazu (tearing); czekanie na vsync jest ograniczone do 3 ms. |
| Tryb pełnoekranowy | **włączony, na monitorze MSI** | Mniej pośredników = mniej opóźnienia |
| Low-queue mode | włączony (jeśli osobna opcja) | — |
| RTSS / nakładki | **wyłączone** | Zgodność RTSS była testowana tylko na RTX 5070 |

**Ile opóźnienia realnie się uzbiera** (dane ze społeczności Veyry + fizyka):

| Źródło | Ile |
|---|---|
| Gra 30 FPS na PS5 renderuje klatkę | ~33 ms (tego nie da się obejść) |
| Przechwytywanie 1080p60 NV12 przez USB | ~10–16 ms |
| Przetwarzanie: XeSS + FG na 3070 Ti | ~10–20 ms |
| Wyświetlenie na 240 Hz | ~4 ms |
| **Razem powyżej tego, co masz na telewizorze** | **~25–40 ms** |

To jest w porządku dla GTA — gry dla jednego gracza, gdzie nie liczysz na reakcje jak w strzelance sieciowej. Dla porównania: przechwytywanie w trybie **30 FPS** zamiast 60 kosztuje ~90 ms zamiast ~40 ms, dlatego **przechwytujemy 60 Hz i usuwamy duplikaty**, a nie przechwytujemy 30.

### 4g. Kolejność ustawiania (żeby nie szukać po omacku)

1. Przechwytywanie 1080p / 59.94 / NV12 → **sprawdź, że widzisz obraz**
2. Dedup **60→30** → **sprawdź, że wejście pokazuje ~30 FPS**
3. Generowanie klatek **XeSS + AMD optical flow, 2X** → sprawdź, że wyjście to ~60 FPS
4. Skalowanie **XeSS → 1440p, Quality**
5. Reflex **On**, budżet opóźnienia **lowest**
6. Zagraj 20 minut. Jeśli stabilne → podnieś mnożnik na **4X**
7. Jeśli 4X jest stabilne i jest zapas → spróbuj **NR 1 warstwa w 1080p**
8. Jeśli wszystko stabilne → spróbuj **HDR** (rozdział 8)

Po każdym kroku patrz na obciążenie GPU. **Jeśli GPU siedzi na 99% — cofnij ostatni krok.** Nasycony GPU to szarpanie i rosnące opóźnienie.

---

## 5. ALTERNATYWA: Lossless Scaling (działa na Windows 10)

**Kiedy to wybrać:** jeśli nie chcesz jeszcze przechodzić na Windows 11, albo jeśli Veyra okaże się u ciebie niestabilna.

- Kup na Steamie: **27,00 zł** — https://store.steampowered.com/app/993090/
- Wymagania minimalne ze strony Steam: *„Windows 10 version 2004”*, DirectX 11
- Wymagania zalecane: *„Windows 11 version 24H2”*, *„GeForce RTX 30 series”* ← dokładnie twoja karta

> ⚠️ **Lossless Scaling jest wyłącznie na Steamie.** W wyszukiwarce wychodzi mnóstwo repozytoriów GitHub typu „Lossless Scaling 3.2.3 release” — **to nie jest oryginał**, to podstawione pliki. Nie pobieraj ich. Nie ma oficjalnego GitHuba tego programu.

### 5a. Problem i obejście

Lossless Scaling **nie ma** usuwania zdublowanych klatek. Jeśli podasz mu obraz 60 Hz z gry 30 FPS, LSFG będzie interpolować między identycznymi klatkami i dostaniesz nierówne tempo (użytkownicy opisują to jako „erratic framerate”).

**Obejście: przechwytuj w 30 FPS, nie w 60.** Wtedy LSFG dostaje 30 prawdziwych, unikalnych klatek.

Kosztuje to więcej opóźnienia (czekasz pełne 33 ms na klatkę zamiast 16 ms), ale daje równe tempo. To główny powód, dla którego polecam Veyrę.

### 5b. Jak to ustawić

Lossless Scaling skaluje **okno**, więc potrzebujesz okna z obrazem z grabbera:

1. Zainstaluj **OBS Studio** (oficjalnie: https://obsproject.com/)
2. Dodaj źródło **Urządzenie przechwytywania wideo** → twój grabber
   - Rozdzielczość: **1920×1080**
   - FPS: **30** (albo 29.97)
   - Format wideo: **NV12** lub **YUY2** (nie MJPEG)
3. Prawy klik na podglądzie → **Projektor okienkowy (Źródło)** → przenieś to okno na monitor MSI, rozciągnij na pełny ekran
4. Wyłącz w OBS nagrywanie i streaming — ma tylko pokazywać obraz

### 5c. Ustawienia Lossless Scaling

| Sekcja | Opcja | Ustaw |
|---|---|---|
| **Frame Generation** | LSFG | **3** (najnowszy model) |
| | Mode | **Fixed** → mnożnik **4X** (30 × 4 = **120 FPS**) |
| | | lub **Adaptive** → cel **120** (daje równiejsze tempo przy spadkach gry) |
| | Performance | **włącz, jeśli GPU przeciążony** (do 2× mniejsze obciążenie, lekko gorsza jakość) |
| | Flow scale | **75%** (jeśli GPU przeciążony → **50%**) |
| **Scaling** | Type | **LS1** albo **FSR** |
| | Mode | **Auto** (dociągnie 1080p → 1440p) |
| **Capture** | Capture API | **WGC** (Windows Graphics Capture) |
| | Queue target | **0** lub **1** ← małe opóźnienie |
| | Max frame latency | **1** |
| **Output** | Sync mode | **Off / Allow tearing** (masz G-Sync) |
| | HDR | **wyłączone** |

> Lossless Scaling wymaga okna lub trybu **bez obramowania** — pełny ekran wyłączny (exclusive fullscreen) nie zadziała. Projektor okienkowy OBS-a jest idealny.
>
> Bonus: masz jeden GPU, więc funkcja **Dual GPU** (odciążanie drugiej karty) cię nie dotyczy. To największa zaleta LS, której nie wykorzystasz.

---

## 6. Windows — ustawienia

**Najpierw punkt przywracania.**

### 6a. Ustawienia systemowe

| Gdzie | Ustaw |
|---|---|
| `Ustawienia` → `Gry` → `Tryb gry` | **Włączony** |
| `Ustawienia` → `Gry` → `Przechwytywanie` / Game DVR | **Wyłączone** (nagrywanie w tle zjada wydajność) |
| `Ustawienia` → `Gry` → `Pasek gier Xbox` | **Wyłączony** |
| `Ustawienia` → `System` → `Ekran` → `Grafika` → `Zmień domyślne ustawienia grafiki` → **Planowanie GPU z akceleracją sprzętową (HAGS)** | **przetestuj A/B — patrz niżej** |
| tam samo: **Optymalizacje dla gier okienkowych** (tylko Win11) | **Włączone** |
| `Panel sterowania` → `Opcje zasilania` | **Zrównoważony** lub **Wysoka wydajność** (nie „Oszczędzanie energii”) |

> ⚠️ **HAGS — u ciebie to NIE jest „po prostu włącz”.** HAGS rezerwuje **do ~1 GB VRAM** na kolejki poleceń po stronie karty. Masz 8 GB, a sama Veyra rezerwuje dodatkowo 1,3–2,3 GB na budżet opóźnienia — więc HAGS może wywołać **więcej** przycinek, niż usuwa. Z drugiej strony poprawia tempo klatek i jest wymagany przez część technik generowania klatek.
>
> **Przetestuj A/B:** 20 minut gry z włączonym, restart, 20 minut z wyłączonym, w tym samym miejscu. Zostaw to, co dało **równiejsze tempo klatek** (nie wyższy średni FPS). Nie chcesz testować? Na 8 GB VRAM z generowaniem klatek postaw na **wyłączone** jako bezpieczniejszy wybór.
>
> Szczegóły i pomiary: `OPTYMALIZACJE.md`, rozdział C3.

### 6b. Monitory

`Ustawienia` → `System` → `Ekran` → `Zaawansowane ustawienia ekranu`:

| Monitor | Ustaw |
|---|---|
| MSI MAG 271QP (główny) | **2560×1440**, **240 Hz** |
| Gigabyte G27Q2 | **2560×1440**, **200 Hz** |

Ustaw MSI jako **główny monitor** (`Ustawienia` → `System` → `Ekran` → zaznacz monitor → *Ustaw jako monitor główny*).

**HDR pulpitu: na start WYŁĄCZONE.**
`Ustawienia` → `System` → `Ekran` → `HDR` → wyłącz dla oba monitory.
Powody: HDR na pulpicie psuje kolory w SDR na drugim monitorze, dokłada pracy GPU, a przy wyłączonym HDR na PS5 nie ma czego przenosić.

### 6c. NVIDIA — sterownik

Sterownik bierz **tylko** z https://www.nvidia.com/Download/index.aspx albo przez **NVIDIA App** (https://www.nvidia.com/en-us/software/nvidia-app/).

Przy instalacji wybierz **Instalacja niestandardowa** → **Wykonaj czystą instalację**. Odznacz to, czego nie używasz.

### 6d. NVIDIA App / Panel sterowania NVIDIA — ustawienia globalne

| Opcja | Ustaw | Dlaczego |
|---|---|---|
| **Tryb niskiego opóźnienia** | **Wł.** (On) | Nie „Ultra” — przy generowaniu klatek Ultra bywa gorsze |
| **Synchronizacja pionowa (Vsync)** | **Wyłączona** | G-Sync załatwia sprawę |
| **Tryb zarządzania energią** | **Preferuj maksymalną wydajność** | Trzyma zegary GPU, zapobiega mikroprzycinkom |
| **Maksymalna liczba klatek** | **Wyłączone** albo 237 | — |
| **Filtrowanie tekstur – jakość** | Wysoka wydajność | nieistotne tutaj |
| **G-Sync** | `Skonfiguruj G-SYNC` → **Włącz** → **dla trybu pełnoekranowego i okienkowego** | Okienkowy jest konieczny — oba programy pracują w oknie |

### 6e. Co WYŁĄCZYĆ w NVIDIA App

| Co | Dlaczego |
|---|---|
| **Nakładka w grze (overlay / ALT+Z)** | Zjada wydajność, koliduje z przechwytywaniem |
| **Natychmiastowa powtórka (Instant Replay) / ShadowPlay** | Nagrywa w tle — niepotrzebne obciążenie |
| **Filtry gry (Game Filters / Freestyle)** | — |
| **Optymalizacja automatyczna gier** | Nadpisuje twoje ustawienia |
| **RTX HDR / RTX Video** dla przeglądarki | Niepotrzebnie trzyma GPU zajęte |
| **NVIDIA Smooth Motion** | Oficjalnie działa tylko na **RTX 40 i 50**. Nie masz jej. Mody „NVSmooth30” na RTX 30 istnieją, ale są eksperymentalne i wymagają grzebania w Profile Inspector po każdej aktualizacji sterownika — **nie polecam, Veyra/LS robi to lepiej i legalnie.** |

### 6f. NZXT CAM vs SignalRGB

**Trzymaj zainstalowany tylko JEDEN program do RGB/chłodzenia.** NZXT CAM i SignalRGB walczą o ten sam kontroler Krakena — stąd twoje wcześniejsze problemy.

Rekomendacja: **zostaw NZXT CAM** (obsługuje pompę i ekran Krakena, czego SignalRGB nie robi dobrze), a SignalRGB **odinstaluj całkowicie** (`Ustawienia` → `Aplikacje`). Po odinstalowaniu zrestartuj komputer.

Jeśli NZXT CAM w tle przeszkadza: w jego ustawieniach wyłącz nakładkę (overlay) i statystyki w grze. Nie wyłączaj samej usługi — pompa potrzebuje sterowania.

---

## 7. Czyszczenie i przyspieszenie Windowsa — tylko bezpieczne narzędzia

**Najpierw punkt przywracania.**

### 7a. Wbudowane narzędzia Windows (zacznij od tych — są darmowe i nic nie psują)

| Narzędzie | Jak uruchomić | Co robi |
|---|---|---|
| **Oczyszczanie dysku** | Start → `cleanmgr` → wybierz C: → **Oczyść pliki systemowe** | Usuwa stare aktualizacje, pliki tymczasowe, kosz. Zwykle odzyskuje 5–30 GB |
| **Czujnik pamięci** | `Ustawienia` → `System` → `Pamięć` → *Czujnik pamięci* → **Włącz** | Automatycznie czyści temp i kosz |
| **Autostart** | `Ctrl+Shift+Esc` → zakładka **Uruchamianie** | Wyłącz wszystko oprócz: antywirus, sterowniki audio, NZXT CAM. **Steam, Discord, Spotify, OneDrive, Adobe → wyłącz** (dalej będą działać, tylko nie wstaną same) |
| **Defragmentacja HDD D:** | Start → `dfrgui` → wybierz **D:** → **Optymalizuj** | Twój D: to HDD 6 TB — defragmentacja ma tu sens. **Dla SSD (C:) NIE defragmentuj** — Windows sam robi TRIM |
| **Sprawdzenie plików systemowych** | PowerShell (admin): `sfc /scannow`, potem `DISM /Online /Cleanup-Image /RestoreHealth` | Naprawia uszkodzone pliki systemowe |
| **Odinstaluj śmieci** | `Ustawienia` → `Aplikacje` → sortuj po dacie | Usuń programy, których nie używasz |

### 7b. Chris Titus WinUtil

**Jedyne oficjalne źródło:**
- Repozytorium: https://github.com/ChrisTitusTech/winutil
- Dokumentacja: https://winutil.christitus.com/
- Licencja: MIT

> ⚠️ W wyszukiwarce wychodzą dziesiątki kopii (`RocGod/winutil`, `teqq/winutil`, `jeetrico/ChrisTitusTool`, SourceForge, gitee…). **Używaj wyłącznie konta `ChrisTitusTech`.**

Uruchomienie — PowerShell **jako administrator**:
```powershell
irm "https://christitus.com/win" | iex
```

**Co zrobić w WinUtil:**

| Zakładka | Co zrobić |
|---|---|
| **Tweaks** | Wybierz preset **Standard** (nie „Minimal”, nie wszystko ręcznie). Kliknij **Run Tweaks**. |
| | WinUtil sam robi punkt przywracania przed zmianami — ale ty zrób swój wcześniej, dla pewności |
| **Install** | Wygodna instalacja programów z oficjalnych źródeł (7-Zip, VLC, OBS, HWiNFO). Przydatne, bezpieczne. |
| **Updates** | Zostaw **Default (Out of Box)**. **Nie wybieraj „Disable All Updates”.** |

**Czego NIE ruszać w WinUtil:**
- ❌ żadnych opcji wyłączających Windows Defender / Windows Security
- ❌ żadnych opcji wyłączających Windows Update
- ❌ `Disable Windows Firewall`
- ❌ eksperymentów z „Remove Microsoft Edge” — potrafi zepsuć aktualizacje
- ❌ „Debloat” na poziomie usuwania Microsoft Store (będzie potrzebny)

Co z presetu Standard jest faktycznie przydatne dla ciebie: wyłączenie telemetrii, wyłączenie Cortany, wyłączenie podpowiedzi/reklam w menu Start, wyłączenie hibernacji (zwalnia kilka GB), wyłączenie zbędnych zadań zaplanowanych.

> **Znacznie szerszy zestaw optymalizacji** — XMP i FCLK, PBO z Curve Optimizerem, undervolt GPU, Resizable BAR, ochrona QD-OLED przed wypaleniem, pełna lista czyszczenia i lista odrzuconych mitów — jest w osobnym pliku **`OPTYMALIZACJE.md`**.

### 7c. Narzędzia, których NIE instalować

❌ **Odrzucone świadomie** (obiecują „boost”, a realnie nic nie dają albo szkodzą):
- CCleaner (od wersji z 2017 r. z aferą malware; „czyszczenie rejestru” to mit)
- Advanced SystemCare, IObit, Glary Utilities, Wise Care
- „Razer Cortex Game Booster”, „Wise Game Booster”, „Smart Game Booster”
- „Driver Booster”, „DriverPack Solution”, „Snappy Driver Installer” — sterowniki bierz od producenta
- cokolwiek nazwane „FPS Unlocker”, „RAM Cleaner”, „Windows 10/11 Lite ISO”, „Ghost Spectre”
- **jakiekolwiek paczki „GTA 6 PC”, „GTA VI Download”, „PS5 60FPS Patch”** — GTA 6 nie ma wersji PC (stan na listopad 2026). W wynikach wyszukiwania jest nawet repozytorium GitHub „PS5-60FPS-Patch-For-GTAVI”, które każe uruchomić `setup.exe` z hasłem na Windowsie. Łatki do PS5 fizycznie nie instalują się z pliku .exe na PC. To złośliwe oprogramowanie.

✅ **Dozwolone i przydatne, z oficjalnych stron:**
- **HWiNFO64** — https://www.hwinfo.com/ — temperatury CPU/GPU/SSD, monitoring na żywo
- **CrystalDiskInfo** — https://crystalmark.info/ — stan SMART dysków
- **OBS Studio** — https://obsproject.com/ — potrzebne dla Lossless Scaling
- **NZXT CAM** — https://nzxt.com/camapp — chłodzenie (już masz)
- **CapFrameX** albo wbudowany licznik FPS — do mierzenia efektu

---

## 8. HDR — dopiero na końcu, jako bonus

Rób to **tylko** jeśli wszystko z rozdziałów 1–7 działa stabilnie. Kolejność:

1. PS5: `Ekran i wideo` → `Wyjście wideo` → **HDR** → `Zawsze włączone` → wykonaj kalibrację HDR
2. Veyra: format pikseli → **P010** (10-bitowy), krzywa koloru wejścia → **PQ HDR10** (ustaw ręcznie, nie „auto”)
3. Windows: `Ustawienia` → `System` → `Ekran` → **HDR** → włącz dla MSI MAG 271QP
4. W Veyrze: jeśli jest opcja ręcznego szczytu jasności — ustaw ją ręcznie (dokumentacja mówi, że Veyra ignoruje niepewne wartości zgłaszane przez monitor i woli ręczne)

**Spodziewane problemy:**
- obraz czerwonawy / spłaszczony → tani grabber przekazuje metadane HDR błędnie. Obejście: raz uruchom OBS z tym grabberem („rozgrzanie”), zamknij, uruchom Veyrę
- większe opóźnienie i mniejszy zapas VRAM → jeśli przycina, wróć do SDR
- twój QD-OLED poradzi sobie z HDR (prawdziwy HDR, nie HDR400), więc warto spróbować — ale jak nie wyjdzie, SDR na QD-OLED i tak wygląda bardzo dobrze

---

## 9. Szybka diagnostyka — co robić, gdy nie działa

| Objaw | Przyczyna | Co zrobić |
|---|---|---|
| Czarny ekran z grabbera | HDCP włączone | Rozdział 2a (podłącz PS5 wprost do TV, wyłącz HDCP) |
| Czarny ekran, HDCP wyłączone | PS5 wysyła 1440p/4K | Ustaw PS5 ręcznie na 1080p (2b) |
| Obraz jest, ale szarpie i tempo jest nierówne | Duplikaty klatek nieusunięte | Włącz **60→30** (4c). Program musi pokazywać ~30 FPS na wejściu |
| Kolory wyprane / czernie szare | Niezgodność zakresu RGB | PS5 → **Ograniczony**, program → **Limited** (2b + 4b) |
| Obraz czerwonawy | Błędne metadane HDR z grabbera | Wyłącz HDR (2c) albo rozgrzej grabber przez OBS (8) |
| Duże opóźnienie sterowania | Pad podłączony do PC | Pad **musi** być na PS5 (2d) |
| Duże opóźnienie obrazu | Reflex na „On + Enhanced”, budżet opóźnienia > lowest, format MJPEG | Rozdział 4f + 4b |
| Mikroprzycinki co kilka sekund | GPU na 99% | Zmniejsz mnożnik 4X→2X, wyłącz NR, Flow scale 50%, włącz Performance mode |
| Program nie widzi grabbera | Inny program go zajął | Zamknij OBS / Kamerę / Discord (Discord potrafi zająć urządzenie wideo) |
| Grabber się rozłącza | Przedni panel / hub / za mało prądu | Włóż w tylny port USB 3.x płyty (3) |
| Dźwięk rozsynchronizowany z obrazem | Dźwięk idzie inną drogą | Słuchawki w pad (2d) albo dźwięk przez grabber — nie mieszaj |

---

## 10. Checklista — do odhaczenia

**PS5**
- [ ] HDCP wyłączone
- [ ] Rozdzielczość ustawiona ręcznie na 1080p
- [ ] Wyjście RGB: Ograniczony
- [ ] HDR: wyłączone (na start)
- [ ] Pad sparowany z PS5, nie z PC

**Sprzęt**
- [ ] Grabber w tylnym porcie USB 3.x płyty głównej
- [ ] Monitory przez DisplayPort
- [ ] Obraz z PS5 widoczny w aplikacji Kamera

**Windows**
- [ ] Punkt przywracania zrobiony
- [ ] Tryb gry włączony, Game DVR wyłączony
- [ ] HAGS przetestowany A/B (na 8 GB VRAM domyślnie raczej wyłączony)
- [ ] MSI = monitor główny, 2560×1440, 240 Hz
- [ ] G27Q2: 200 Hz
- [ ] G-Sync włączony dla pełnego ekranu i okna
- [ ] HDR pulpitu wyłączone
- [ ] Autostart przejrzany
- [ ] Tylko jeden program RGB (NZXT CAM)

**NVIDIA**
- [ ] Najnowszy sterownik z nvidia.com, czysta instalacja
- [ ] Tryb niskiego opóźnienia: Wł.
- [ ] Vsync: wyłączony
- [ ] Zarządzanie energią: maksymalna wydajność
- [ ] Nakładka, Instant Replay, filtry: wyłączone

**Program**
- [ ] SHA256 pobranego pliku sprawdzone
- [ ] Przechwytywanie: 1080p / 59.94 / NV12 / Limited / 709
- [ ] **Dedup 60→30 włączony, wejście pokazuje ~30 FPS**
- [ ] Generowanie: XeSS FG + AMD optical flow, 2X (potem 4X)
- [ ] Skalowanie: XeSS → 2560×1440, Quality
- [ ] NR wyłączone (na start)
- [ ] Reflex: On (nie Enhanced)
- [ ] Budżet opóźnienia: lowest
- [ ] Limit wyjścia: 120

---

## Źródła

- Veyra NR — repozytorium i wydania: https://github.com/Likely7/Veyra-NRVideo/releases/latest
- Veyra NR — wiki (przegląd, ustawienia, zakup karty): https://github.com/Likely7/Veyra-NRVideo/wiki/Guide-00-Overview
- Lossless Scaling na Steamie (cena i wymagania): https://store.steampowered.com/app/993090/
- Chris Titus WinUtil: https://github.com/ChrisTitusTech/winutil · https://winutil.christitus.com/
- HDCP na PS5: https://www.powerpyx.com/ps5-how-to-disable-hdcp/
- Specyfikacja układu MS2131: https://www.ultrasemi.com/en/ic/macrosilicon/ms2131
- NVIDIA Smooth Motion tylko na RTX 40/50: https://www.techpowerup.com/352989/nvidia-smooth-motion-reaches-geforce-rtx-30-series-ampere-gpus-through-mods
- GTA 6 bez trybu 60 FPS na PS5: https://www.engadget.com/2320281/why-gta-6-no-60-fps-performance-mode/
