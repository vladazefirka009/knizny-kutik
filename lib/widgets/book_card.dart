import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavorite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                height: 150,
                child: BookCover(coverUrl: book.coverUrl, compact: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: book.isFavorite
                              ? 'Odobrať z obľúbených'
                              : 'Pridať medzi obľúbené',
                          onPressed: onFavorite,
                          icon: Icon(
                            book.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: book.isFavorite
                                ? const Color(0xFFC15A56)
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book.isFinished
                          ? 'Prečítaná'
                          : book.readingProgress == 0
                          ? 'Ešte nečítaná'
                          : 'Rozčítaná',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.primary),
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: book.readingProgress / 100,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${book.readingProgress} %',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
