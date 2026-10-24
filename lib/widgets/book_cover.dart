import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  const BookCover({super.key, this.coverUrl, this.compact = false});

  final String? coverUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 12 : 16);
    final url = coverUrl;

    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: const Color(0xFFEFE9DF),
        child: url == null || url.isEmpty
            ? _placeholder(context)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(context),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(context),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: compact ? 32 : 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(
              'Knižný kútik',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}
