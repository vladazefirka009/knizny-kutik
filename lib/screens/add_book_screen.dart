import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/library_provider.dart';
import '../widgets/book_cover.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<_BookSuggestion> _suggestions = [];
  String? _coverUrl;
  String? _errorMessage;
  int? _year;
  int _progress = 0;
  bool _isSearching = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _searchOpenLibrary() async {
    final query = _titleController.text.trim();
    if (query.length < 2) {
      setState(() => _errorMessage = 'Zadajte aspoň dve písmená názvu.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _suggestions = [];
    });
    try {
      final uri = Uri.https('openlibrary.org', '/search.json', {
        'q': query,
        'limit': '8',
        'fields': 'title,author_name,first_publish_year,cover_i',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw const FormatException();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final docs = data['docs'] as List<dynamic>? ?? const [];
      final suggestions = docs
          .whereType<Map<String, dynamic>>()
          .map(_BookSuggestion.fromJson)
          .where((book) => book.title.isNotEmpty && book.author.isNotEmpty)
          .take(8)
          .toList();
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        if (suggestions.isEmpty) {
          _errorMessage = 'Nenašli sme tento titul. Pridajte ho ručne.';
        }
      });
    } on FormatException {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Katalóg neodpovedal. Knihu môžete vyplniť ručne.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Nepodarilo sa pripojiť ku katalógu. Skúste to neskôr alebo pokračujte ručne.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(_BookSuggestion suggestion) {
    setState(() {
      _titleController.text = suggestion.title;
      _authorController.text = suggestion.author;
      _year = suggestion.year;
      _coverUrl = suggestion.coverUrl;
      _suggestions = [];
      _errorMessage = null;
    });
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    final book = Book(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      description: _descriptionController.text.trim(),
      coverUrl: _coverUrl,
      year: _year,
      readingProgress: _progress,
    );
    await context.read<LibraryProvider>().addBook(book);
    if (mounted) Navigator.pop<Book>(context, book);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pridať knihu')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Nový príbeh na poličke',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vyhľadajte titul v Open Library alebo údaje zadajte sami.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('bookTitleField'),
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Názov knihy',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Doplňte názov knihy.'
                        : null,
                    onChanged: (_) {
                      if (_coverUrl != null) setState(() => _coverUrl = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isSearching ? null : _searchOpenLibrary,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.travel_explore_rounded),
                      label: Text(
                        _isSearching
                            ? 'Vyhľadávam v katalógu…'
                            : 'Nájsť obálku v Open Library',
                      ),
                    ),
                  ),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Vyberte správne vydanie',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._suggestions.map(
                      (suggestion) => _SuggestionTile(
                        suggestion: suggestion,
                        onTap: () => _selectSuggestion(suggestion),
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!, style: TextStyle(color: colors.error)),
                  ],
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _authorController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Autor alebo autorka',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Doplňte autora.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (_year != null) ...[
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 17,
                      ),
                      label: Text('Vydanie: $_year'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Krátky popis (nepovinné)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Prečítané: $_progress %',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        _progress == 0
                            ? 'Začnem neskôr'
                            : _progress == 100
                            ? 'Dočítaná!'
                            : 'Čítam',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _progress.toDouble(),
                    max: 100,
                    divisions: 20,
                    onChanged: (value) =>
                        setState(() => _progress = value.round()),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const Key('saveBookButton'),
                    onPressed: _isSaving ? null : _saveBook,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(_isSaving ? 'Ukladám…' : 'Uložiť do knižnice'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookSuggestion {
  const _BookSuggestion({
    required this.title,
    required this.author,
    this.year,
    this.coverUrl,
  });

  final String title;
  final String author;
  final int? year;
  final String? coverUrl;

  factory _BookSuggestion.fromJson(Map<String, dynamic> json) {
    final authors =
        (json['author_name'] as List<dynamic>?)?.whereType<String>().toList() ??
        const [];
    final coverId = json['cover_i'] as int?;
    return _BookSuggestion(
      title: json['title'] as String? ?? '',
      author: authors.isEmpty ? '' : authors.first,
      year: json['first_publish_year'] as int?,
      coverUrl: coverId == null
          ? null
          : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final _BookSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: SizedBox(
        width: 42,
        height: 52,
        child: BookCover(coverUrl: suggestion.coverUrl, compact: true),
      ),
      title: Text(
        suggestion.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          suggestion.author,
          if (suggestion.year != null) '${suggestion.year}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.add_circle_outline_rounded),
      onTap: onTap,
    ),
  );
}
