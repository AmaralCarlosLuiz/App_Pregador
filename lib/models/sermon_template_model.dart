class SermonTemplate {
  final String id;
  final String title;
  final String theme;
  final String keyVerse;
  final String sermonType;
  final List<String> tags;
  final Map<String, dynamic> content;

  const SermonTemplate({
    required this.id,
    required this.title,
    required this.theme,
    required this.keyVerse,
    this.sermonType = 'Expositivo',
    this.tags = const [],
    this.content = const {},
  });

  factory SermonTemplate.fromJson(Map<String, dynamic> json) {
    return SermonTemplate(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      keyVerse: json['key_verse'] as String? ?? '',
      sermonType: json['sermon_type'] as String? ?? 'Expositivo',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme,
      'key_verse': keyVerse,
      'sermon_type': sermonType,
      'tags': tags,
      'content': content,
    };
  }
}
