import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_books.dart';
import '../models/book.dart';

enum BookFilter { all, reading, finished, favorites }

class LibraryProvider extends ChangeNotifier {
  static const _storageKey = 'knizny_kutik_books_v1';

  LibraryProvider() : _books = List<Book>.of(sampleBooks) {
    unawaited(loadBooks());
  }

  final List<Book> _books;
  BookFilter _filter = BookFilter.all;
  String _query = '';
  bool _isReady = false;

  List<Book> get books => List.unmodifiable(_books);
  BookFilter get filter => _filter;
  String get query => _query;
  bool get isReady => _isReady;

  List<Book> get visibleBooks {
    final normalisedQuery = _query.trim().toLowerCase();
    return _books.where((book) {
      final matchesFilter = switch (_filter) {
        BookFilter.all => true,
        BookFilter.reading => book.readingProgress > 0 && !book.isFinished,
        BookFilter.finished => book.isFinished,
        BookFilter.favorites => book.isFavorite,
      };
      final matchesSearch =
          normalisedQuery.isEmpty ||
          book.title.toLowerCase().contains(normalisedQuery) ||
          book.author.toLowerCase().contains(normalisedQuery);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get readingCount => _books
      .where((book) => book.readingProgress > 0 && !book.isFinished)
      .length;

  Future<void> loadBooks() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_storageKey);
      if (saved != null) {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _books
          ..clear()
          ..addAll(
            decoded.map(
              (item) => Book.fromJson(Map<String, dynamic>.from(item as Map)),
            ),
          );
      }
    } catch (_) {
      // Predvolené knihy zostanú dostupné aj pri poškodenom úložisku.
    }
    _isReady = true;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(BookFilter value) {
    _filter = value;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.insert(0, book);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    _update(id, (book) => book.copyWith(isFavorite: !book.isFavorite));
    await _persist();
  }

  Future<void> updateProgress(String id, int progress) async {
    _update(
      id,
      (book) => book.copyWith(readingProgress: progress.clamp(0, 100)),
    );
    await _persist();
  }

  Future<void> removeBook(String id) async {
    _books.removeWhere((book) => book.id == id);
    notifyListeners();
    await _persist();
  }

  void _update(String id, Book Function(Book) update) {
    final index = _books.indexWhere((book) => book.id == id);
    if (index == -1) return;
    _books[index] = update(_books[index]);
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final encoded = jsonEncode(_books.map((book) => book.toJson()).toList());
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, encoded);
    } catch (_) {
      // Zmena zostáva dostupná počas behu aplikácie aj bez perzistencie.
    }
  }
}
