# Knižný kútik

Jednoduchá Flutter aplikácia na správu osobnej knižnice. Knihy možno vyhľadávať vo verejnom katalógu Open Library alebo pridať ručne, sledovať stav čítania, označiť obľúbené tituly a knižnicu vyhľadávať či filtrovať. Zmeny sa ukladajú lokálne v zariadení.

## Spustenie

1. Nainštalujte Flutter SDK a pripravte Android emulátor alebo pripojte zariadenie.
2. V koreňovom adresári projektu spustite `flutter pub get`.
3. Spustite aplikáciu príkazom `flutter run`.

Na zobrazenie v prehliadači môžete použiť `flutter run -d chrome`. Vyhľadávanie v Open Library vyžaduje internet; pri nedostupnosti katalógu možno knihu vždy zadať ručne.

Vo Windows rozbaľte projekt do cesty bez diakritiky (napríklad `C:\flutter\knizny-kutik`), aby Android SDK správne spracovalo cestu k projektu.

## Štruktúra

- `lib/models/book.dart` – dátový model knihy a JSON serializácia.
- `lib/providers/library_provider.dart` – stav knižnice, filtre a lokálne ukladanie.
- `lib/screens/` – domovská obrazovka, detail knihy a formulár na pridanie.
- `lib/data/sample_books.dart` – ukážkové knihy pri prvom spustení.
- `lib/widgets/` – opakovane použité karty a obálky.

Stav zabezpečuje Provider, údaje sa ukladajú cez SharedPreferences. Katalóg používa Open Library Search API: https://openlibrary.org/dev/docs/api/search
