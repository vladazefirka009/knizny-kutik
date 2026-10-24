import '../models/book.dart';

const sampleBooks = <Book>[
  Book(
    id: 'dune',
    title: 'Duna',
    author: 'Frank Herbert',
    description: 'Legendárny sci-fi román o planéte Arrakis, vzácnom korení a odvahe zmeniť vlastný osud.',
    year: 1965,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780441172719-M.jpg',
    readingProgress: 62,
  ),
  Book(
    id: 'atomic-habits',
    title: 'Atómové návyky',
    author: 'James Clear',
    description: 'Praktický sprievodca drobnými zmenami, vďaka ktorým vznikajú dobré návyky a miznú tie zlé.',
    year: 2018,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780735211292-M.jpg',
    readingProgress: 100,
    isFavorite: true,
  ),
  Book(
    id: 'hobbit',
    title: 'Hobit',
    author: 'J. R. R. Tolkien',
    description: 'Bilbo Bublík sa vydáva na cestu, ktorá vedie cez Hmlisté hory až k pokladu stráženému drakom.',
    year: 1937,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780547928227-M.jpg',
    isFavorite: true,
  ),
  Book(
    id: 'fahrenheit-451',
    title: '451 stupňov Fahrenheita',
    author: 'Ray Bradbury',
    description: 'Nadčasový príbeh o svete bez kníh a človeku, ktorý sa odváži spochybniť pravidlá.',
    year: 1953,
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9781451673319-M.jpg',
  ),
];
