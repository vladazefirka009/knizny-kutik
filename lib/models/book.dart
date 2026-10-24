class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.coverUrl,
    this.year,
    this.readingProgress = 0,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final String? coverUrl;
  final int? year;
  final int readingProgress;
  final bool isFavorite;

  bool get isFinished => readingProgress == 100;

  Book copyWith({int? readingProgress, bool? isFavorite, String? coverUrl}) {
    return Book(
      id: id,
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year,
      readingProgress: readingProgress ?? this.readingProgress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'coverUrl': coverUrl,
    'year': year,
    'readingProgress': readingProgress,
    'isFavorite': isFavorite,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    description: json['description'] as String? ?? '',
    coverUrl: json['coverUrl'] as String?,
    year: json['year'] as int?,
    readingProgress: (json['readingProgress'] as int? ?? 0).clamp(0, 100),
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
}
