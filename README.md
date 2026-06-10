# Van Buren

Van Buren to gra RPG osadzona w postapokaliptycznym świecie inspirowanym klimatem serii *Metro* oraz klasycznych gier cRPG, takich jak *Fallout*. Produkcja wykorzystuje dwuwymiarową grafikę pixel art i widok z góry, pozwalając graczowi eksplorować opustoszałe stacje krakowskiego metra.

Fabuła opowiada historię poszukiwań legendarnego **Laguna** – tajemniczego i niezwykle rzadkiego przedstawiciela gatunku, którego istnienie dla wielu mieszkańców podziemi jest jedynie legendą. Podczas swojej podróży gracz przemierza kolejne stacje metra, mierzy się z niebezpiecznymi stworzeniami, rozwiązuje zagadki oraz odkrywa ślady dawnego świata ukryte w notatkach i rozmowach z napotkanymi postaciami.

## Użyte narzędzia

Gra została stworzona przy użyciu silnika **Godot Engine 4**.

## Opis mechaniki

### Świat gry

Świat gry podzielony jest na siatkę kwadratowych pól, po których poruszają się wszystkie postacie. Kamera ustawiona jest w widoku z góry, zapewniając graczowi pełny wgląd w najbliższe otoczenie.

Rozgrywka odbywa się na trzech różnych stacjach opuszczonego krakowskiego metra. Początkowo dostępna jest jedynie pierwsza lokacja, a odblokowywanie kolejnych wymaga wykonania określonych zadań fabularnych. Przemieszczanie się pomiędzy stacjami odbywa się za pomocą pociągu.

### Sterowanie

* **Lewy przycisk myszy** – poruszanie postacią oraz interakcja z elementami interfejsu użytkownika.
* **Prawy przycisk myszy** – wykonywanie ataków podczas walki. Gdy przeciwnik znajduje się w zasięgu aktualnie wyposażonej broni, zostaje podświetlony na czerwono i może zostać zaatakowany.
* **Klawisz E** – interakcja z obiektami znajdującymi się w pobliżu postaci, takimi jak przełączniki, drzwi, notatki czy elementy związane z zadaniami.

Informacje o interakcjach, dialogi oraz komunikaty fabularne wyświetlane są w panelu tekstowym znajdującym się w prawym dolnym rogu ekranu.

### Postać gracza

Gracz może swobodnie eksplorować dostępne stacje metra, rozmawiać z napotkanymi postaciami oraz wykonywać zadania związane z głównym wątkiem fabularnym.

Postać posiada **14 punktów zdrowia**, które mogą być odnawiane przy użyciu przedmiotów leczniczych odnajdywanych podczas eksploracji. W trakcie walki gracz może przemieścić się maksymalnie o **4 pola** podczas jednej tury.

### Interfejs użytkownika

Interfejs użytkownika podzielony jest na dwa główne obszary:

#### Dolny panel

Dolna część ekranu zawiera interaktywną mapę sieci metra. Przedstawia ona układ dostępnych stacji oraz umożliwia wybór celu podróży po wejściu do pociągu.

Po prawej stronie dolnego panelu znajduje się okno tekstowe wyświetlające:

* dialogi,
* informacje o interakcjach,
* treść odnalezionych notatek,
* wskazówki dotyczące zagadek,
* komunikaty związane z rozgrywką.

#### Górny prawy panel

W prawym górnym rogu ekranu znajdują się tabliczki informacyjne prezentujące:

* aktualną stację metra,
* poziom zdrowia postaci.

W tym samym obszarze znajduje się również menu umożliwiające zmianę aktualnie używanej broni.

### System walki

Walka odbywa się w systemie turowym. Gracz oraz przeciwnicy wykonują swoje ruchy naprzemiennie zgodnie z ustaloną kolejnością inicjatywy.

Podczas swojej tury uczestnik walki może:

1. wykonać ruch,
2. przeprowadzić atak.

Tura kończy się po wykonaniu ataku lub po zakończeniu ruchu, jeśli żaden przeciwnik nie znajduje się w zasięgu.

Gracz ma do dyspozycji dwa rodzaje broni:

* **Nóż** – broń do walki wręcz dostępna od początku gry.
* **Kusza** – broń dystansowa odblokowywana w dalszej części rozgrywki.

Przeciwnicy dysponują jednym rodzajem ataku, jednak różnią się zachowaniem oraz parametrami, co sprawia, że kolejne starcia wymagają stosowania różnych strategii.

### Zadania i zagadki logiczne

Głównym celem gracza jest odnalezienie legendarnego **Laguna**. Wątek fabularny prowadzi przez wszystkie dostępne stacje metra, stopniowo odsłaniając historię świata i przybliżając gracza do celu podróży.

Gra zawiera dwie zagadki logiczne.

#### Naprawa pociągu

Aby uzyskać możliwość podróżowania pomiędzy stacjami, gracz musi naprawić uszkodzony pociąg. Naprawy należy wykonywać w odpowiedniej kolejności. W przypadku popełnienia błędu postęp zostaje zresetowany i konieczne jest rozpoczęcie procedury od początku.

Wskazówki dotyczące prawidłowej kolejności działań znajdują się w notatkach rozrzuconych po pierwszej stacji.

#### Przełączniki świateł

Na drugiej stacji gracz napotyka zamknięte drzwi blokujące dalszą drogę. Aby je otworzyć, należy ustawić zestaw przełączników w odpowiedniej konfiguracji.

Rozmieszczenie świecących lamp na stacji stanowi wskazówkę dotyczącą poprawnego ustawienia przełączników. Gdy wszystkie światła zostaną aktywowane, drzwi automatycznie się otworzą.

## Użyte assety

Linki do assetów pobranych z Internetu:

* https://moolabs.itch.io/leveltilesets-industrial
* https://kyle-d.itch.io/free-isometric-tile-pack
* https://vinchy007.itch.io/top-down-apocaliptic-tileset
* https://thelazystone.itch.io/post-apocalypse-pixel-art-asset-pack
* https://opengameart.org/content/grassland-tileset
* https://pop-shop-packs.itch.io/pigeons-2d-pixel-asset-pack
* https://kangjung.itch.io/pigeon-pixel
* https://craftpix.net/freebies/free-top-down-hunt-animals-pixel-sprite-pack/
* https://reakain.itch.io/gb-studio-trains
* https://cuddle-bug.itch.io/apocalypse
* https://elthen.itch.io/2d-pixel-art-pidgeon-sprites
* https://lyaseek.itch.io/miniffanimals
* https://pixabay.com/sound-effects/city-moscow-metro-station-22542/
* https://pixabay.com/sound-effects/film-special-effects-hit-swing-sword-small-2-95566/
* https://pixabay.com/sound-effects/film-special-effects-knife-swish-1-82559/
* https://pixabay.com/sound-effects/film-special-effects-9mm-pistol-shoot-short-reverb-7152/
* https://pixabay.com/sound-effects/nature-pigeons-flying-6351/
* https://pixabay.com/sound-effects/film-special-effects-oink-oink-228771/
* https://pixabay.com/sound-effects/film-special-effects-walking-96582/
* https://pixabay.com/sound-effects/city-footsteps-hallway-6417/
* https://pixabay.com/sound-effects/musical-fuse-box-klick-106954/
* https://pixabay.com/sound-effects/film-special-effects-light-switch-81967/

Pozostałe grafiki, elementy interfejsu użytkownika oraz część zasobów wizualnych zostały przygotowane samodzielnie przez autorów projektu.

## Wykorzystanie AI

Podczas tworzenia gry wykorzystano generatywną sztuczną inteligencję jako narzędzie wspomagające proces projektowania fabuły oraz przygotowywania części dialogów.

Niektóre wykorzystane assety pochodzące z zewnętrznych źródeł zostały oznaczone przez ich autorów jako wygenerowane lub wspomagane przez sztuczną inteligencję.

W samej rozgrywce sztuczna inteligencja nie odgrywa znaczącej roli. Przeciwnicy sterowani są przez proste systemy decyzyjne i zestaw reguł określających ich zachowanie podczas eksploracji oraz walki.

## Uruchamianie gry

Projekt został przygotowany w silniku **Godot Engine 4**.

Aby uruchomić grę:

1. Zainstaluj Godot Engine w wersji 4.x.
2. Pobierz lub sklonuj repozytorium projektu.
3. Uruchom Godot i wybierz opcję **Import Project**.
4. Wskaż plik `project.godot` znajdujący się w katalogu głównym projektu.
5. Po zaimportowaniu projektu otwórz go z poziomu menedżera projektów Godota.
6. Naciśnij przycisk **Run Project** (ikona ▶ w prawym górnym rogu edytora) lub użyj klawisza **F5**.

Gra zostanie uruchomiona w osobnym oknie wraz z domyślnie skonfigurowanymi ustawieniami projektu.

## Zrzuty ekranu

*(miejsce na zrzuty ekranu przedstawiające rozgrywkę)*

---

Projekt realizowany w ramach kursu *Technologie Gier Komputerowych* przez:

**Kinga Bunkowska** – [@KingaBunkowska](https://github.com/KingaBunkowska)

**Albert Pęciak** – [@AlbertPec](https://github.com/AlbertPec)
