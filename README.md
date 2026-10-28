# macOS Pomodoro

Minimalistyczny timer Pomodoro dla macOS w formie szklanego widżetu przypiętego do krawędzi ekranu. Aplikacja jest napisana natywnie w Swift i SwiftUI (z AppKit tam, gdzie SwiftUI nie wystarcza), nie ma ikony w Docku i żyje w pasku menu.

## Funkcje

- **Timer sesji i przerw** z pauzą i resetem. Długość sesji (1–180 min) i przerwy (1–60 min) ustawiasz w menu.
- **Długa przerwa** po czterech sesjach (domyślnie 15 min, 0 wyłącza ją).
- **Kropki sesji** pokazujące postęp w czteroelementowym cyklu.
- **Widżet przypięty do krawędzi ekranu** (lewej, prawej, górnej lub dolnej), który można przeciągać wzdłuż tej krawędzi, żeby nie zasłaniał treści innych aplikacji. Pozycja jest zapamiętywana osobno dla każdej krawędzi.
- **Tryb kompaktowy:** w trakcie odliczania widżet po 3 sekundach bez kursora płynnie zwija się do samego pierścienia z czasem i kropkami, a po najechaniu rozwija się z powrotem.
- **Regulowany rozmiar** widżetu (zmniejszenie o 25–50%).
- **Wygląd „szkła":** rozmycie tła, czerwony odcień sesji pracy i turkusowy przerwy, pierścień postępu z poświatą.
- **Ikona w pasku menu** z czasem pozostałym do końca bieżącej fazy.
- **Powiadomienia systemowe** na koniec sesji i przerwy.
- **Statystyki:** liczba sesji, odsetek sesji ukończonych bez przerwania i średni czas sesji.
- **Uruchamianie przy logowaniu** do macOS.

## Wymagania

- macOS 14 (Sonoma) lub nowszy
- Xcode 15 lub nowszy

## Uruchomienie z kodu źródłowego

Repozytorium zawiera pliki źródłowe w folderze `PomodoroWidget/` oraz ikonę w `Design/`. Jeśli nie ma w nim jeszcze projektu Xcode (`PomodoroWidget.xcodeproj`), utwórz go tak:

1. W Xcode: *File → New → Project → macOS → App*. Nazwa: `PomodoroWidget`, interfejs: SwiftUI, język: Swift.
2. Usuń wygenerowane pliki `PomodoroWidgetApp.swift` i `ContentView.swift`.
3. Przeciągnij wszystkie pliki z folderu `PomodoroWidget/` do projektu (zaznacz *Copy items if needed* i właściwy cel).
4. W `Assets.xcassets` zastąp `AppIcon` folderem `Design/AppIcon.appiconset`.
5. W ustawieniach celu ustaw *Minimum Deployments* na macOS 14.0.
6. Uruchom aplikację (⌘R).

Po starcie nie pojawi się zwykłe okno. Zobaczysz widżet przy krawędzi ekranu i ikonę zegara w pasku menu. Aplikację zamkniesz z okienka ustawień (*Quit Pomodoro*) albo przyciskiem Stop w Xcode.

### Eksport do `.app`

*Product → Archive → Distribute App → Copy App*, a następnie przeciągnij aplikację do folderu *Programy*. Aplikacja nie jest podpisana ani notaryzowana, więc przy pierwszym uruchomieniu macOS może ją zablokować. Otwórz ją wtedy prawym przyciskiem myszy (*Otwórz*) albo zezwól w *Ustawieniach systemowych → Prywatność i ochrona*. Uruchamianie przy logowaniu działa najlepiej dla aplikacji z folderu *Programy*.

## Obsługa

- **START / PAUSE / RESUME** rozpoczyna, wstrzymuje i wznawia odliczanie, **RESET** wraca do gotowości.
- **Przeciągnij** widżet za tło, pierścień lub napisy, żeby przesunąć go wzdłuż krawędzi.
- **Ikona zegara w pasku menu** otwiera okienko z ustawieniami i statystykami.

### Ustawienia

| Ustawienie | Opis |
| --- | --- |
| Session | Długość sesji pracy, 1–180 min |
| Break | Długość zwykłej przerwy, 1–60 min |
| Long break | Długość długiej przerwy po 4 sesjach, 5–60 min (0 = wyłączona) |
| Size reduction | Zmniejszenie widżetu o 25–50% |
| Screen edge | Krawędź ekranu, do której przypięty jest widżet |
| Show time in menu bar | Czas w pasku menu obok ikony |
| Compact mode | Automatyczne zwijanie widżetu w trakcie odliczania |
| Center widget on edge | Przywraca widżet na środek bieżącej krawędzi |
| Launch at login | Uruchamianie aplikacji przy logowaniu |

### Statystyki

- Pauza w trakcie sesji pracy liczy się jako przerwanie sesji.
- Reset przed końcem sesji zapisuje ją jako przerwaną. Przerwane sesje krótsze niż 10 sekund są pomijane.
- Dane są zapisywane lokalnie w pliku `~/Library/Application Support/PomodoroWidget/sessions.json`. Przycisk *Reset statistics* w menu czyści historię.

## Struktura repozytorium

```
macos-pomodoro/
├── README.md
├── .gitignore
├── Design/
│   ├── AppIcon.appiconset/        # komplet ikon aplikacji do Assets.xcassets
│   └── icon_1024_master.png       # ikona w rozmiarze 1024 px
└── PomodoroWidget/
    ├── PomodoroWidgetApp.swift        # punkt wejścia, ikona i czas w pasku menu
    ├── PomodoroTimer.swift            # logika timera, faz, cyklu sesji i długiej przerwy
    ├── PomodoroSettings.swift         # klucze i wartości ustawień (UserDefaults)
    ├── WidgetView.swift               # widżet: szkło, pierścień, przyciski, tryb kompaktowy
    ├── WidgetPanelController.swift    # bezramkowe okno przypięte do krawędzi, przeciąganie
    ├── ScreenEdge.swift               # krawędzie ekranu i kształt widżetu
    ├── SettingsView.swift             # okienko ustawień i statystyk w pasku menu
    ├── StatsStore.swift               # zapis i obliczanie statystyk (JSON)
    ├── NotificationService.swift      # powiadomienia systemowe
    ├── MenuBarImage.swift             # ikona i czas w pasku menu o stałej szerokości
    └── LaunchAtLogin.swift            # uruchamianie przy logowaniu (SMAppService)
```

## Uwagi techniczne

- Widżet to bezramkowy `NSPanel` (zawsze na wierzchu, bez przejmowania fokusu), w którym osadzono widok SwiftUI. Dzięki temu można go przykleić do dowolnej krawędzi widocznego obszaru ekranu.
- Szkło to `NSVisualEffectView` z rozmyciem tła, na które nakładany jest kolor fazy.
- Odliczanie opiera się na dacie zakończenia, więc jest odporne na opóźnienia zegara aplikacji.

## Licencja

Nie określono.
