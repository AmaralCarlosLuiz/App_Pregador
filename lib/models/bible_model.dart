class BibleBookMetadata {
  final String id;
  final String name;
  final String testament; // 'Antigo' ou 'Novo'
  final String category; // 'Pentateuco', 'Históricos', 'Evangelhos', etc.
  final int totalChapters;

  const BibleBookMetadata({
    required this.id,
    required this.name,
    required this.testament,
    required this.category,
    required this.totalChapters,
  });

  bool get isOldTestament => testament == 'Antigo';
  bool get isNewTestament => testament == 'Novo';
}

class BibleVerse {
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String version;

  const BibleVerse({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.version = 'ARC',
  });

  String get reference => '$bookName $chapter:$verse';
  String get formattedCitation => '"$text" — $reference ($version)';

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'version': version,
      };

  factory BibleVerse.fromJson(Map<String, dynamic> json) => BibleVerse(
        bookId: json['bookId'] as String? ?? '',
        bookName: json['bookName'] as String? ?? '',
        chapter: json['chapter'] as int? ?? 1,
        verse: json['verse'] as int? ?? 1,
        text: json['text'] as String? ?? '',
        version: json['version'] as String? ?? 'ARC',
      );
}

class BibleBookmark {
  final String id;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String version;
  final String colorHex;
  final String? note;
  final DateTime createdAt;

  const BibleBookmark({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.version = 'ARC',
    this.colorHex = '#D97706',
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'version': version,
        'colorHex': colorHex,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BibleBookmark.fromJson(Map<String, dynamic> json) => BibleBookmark(
        id: json['id'] as String? ?? '',
        bookId: json['bookId'] as String? ?? '',
        bookName: json['bookName'] as String? ?? '',
        chapter: json['chapter'] as int? ?? 1,
        verse: json['verse'] as int? ?? 1,
        text: json['text'] as String? ?? '',
        version: json['version'] as String? ?? 'ARC',
        colorHex: json['colorHex'] as String? ?? '#D97706',
        note: json['note'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
