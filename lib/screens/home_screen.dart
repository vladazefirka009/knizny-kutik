import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/library_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddBook() async {
    final book = await Navigator.push<Book>(
      context,
      MaterialPageRoute<Book>(builder: (_) => const AddBookScreen()),
    );
    if (!mounted || book == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('„${book.title}“ pribudla do knižnice.')),
    );
  }

  void _openDetails(Book book) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => BookDetailScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<LibraryProvider>(
          builder: (context, library, _) {
            final visibleBooks = library.visibleBooks;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildHeader(context, library),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(child: _buildSearch(context)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildFilters(context, library),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sectionTitle(library.filter),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${visibleBooks.length} kníh',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (visibleBooks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, library),
                  )
                else
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.crossAxisExtent <= 0) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                        sliver: SliverGrid.builder(
                          itemCount: visibleBooks.length,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    constraints.crossAxisExtent >= 720
                                    ? 430
                                    : 600,
                                mainAxisExtent: 178,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemBuilder: (context, index) {
                            final book = visibleBooks[index];
                            return BookCard(
                              book: book,
                              onTap: () => _openDetails(book),
                              onFavorite: () => library.toggleFavorite(book.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBook,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Pridať knihu'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LibraryProvider library) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Knižný kútik',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.bookmark_added_outlined, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              library.isReady ? 'Uložené' : 'Načítavam…',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Vitajte vo svojej\nknižnici.',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          'Všetky vaše príbehy na jednom mieste.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'V knižnici',
                value: '${library.books.length}',
                icon: Icons.menu_book_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Rozčítané',
                value: '${library.readingCount}',
                icon: Icons.auto_awesome_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) => TextField(
    controller: _searchController,
    onChanged: context.read<LibraryProvider>().setQuery,
    decoration: InputDecoration(
      hintText: 'Hľadať v mojej knižnici…',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _searchController.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Vymazať hľadanie',
              onPressed: () {
                _searchController.clear();
                context.read<LibraryProvider>().setQuery('');
              },
              icon: const Icon(Icons.close_rounded),
            ),
    ),
  );

  Widget _buildFilters(BuildContext context, LibraryProvider library) {
    const filters = [
      (BookFilter.all, 'Všetky'),
      (BookFilter.reading, 'Rozčítané'),
      (BookFilter.finished, 'Prečítané'),
      (BookFilter.favorites, 'Obľúbené'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter.$2),
                  selected: library.filter == filter.$1,
                  onSelected: (_) => library.setFilter(filter.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, LibraryProvider library) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 48),
          const SizedBox(height: 12),
          Text(
            library.query.isNotEmpty
                ? 'Nič sme nenašli'
                : 'Polička je zatiaľ prázdna',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Skúste iné hľadanie alebo pridajte knihu do svojej knižnice.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _sectionTitle(BookFilter filter) => switch (filter) {
    BookFilter.all => 'Moje knihy',
    BookFilter.reading => 'Rozčítané knihy',
    BookFilter.finished => 'Prečítané knihy',
    BookFilter.favorites => 'Obľúbené knihy',
  };
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
