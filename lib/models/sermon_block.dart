class HomileticBlock {
  final String id;
  final String title;
  final String biblicalReference;
  final String explanation;
  final String illustration;
  final String application;
  final int orderIndex;

  const HomileticBlock({
    required this.id,
    required this.title,
    this.biblicalReference = '',
    this.explanation = '',
    this.illustration = '',
    this.application = '',
    this.orderIndex = 0,
  });

  HomileticBlock copyWith({
    String? id,
    String? title,
    String? biblicalReference,
    String? explanation,
    String? illustration,
    String? application,
    int? orderIndex,
  }) {
    return HomileticBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      biblicalReference: biblicalReference ?? this.biblicalReference,
      explanation: explanation ?? this.explanation,
      illustration: illustration ?? this.illustration,
      application: application ?? this.application,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'biblicalReference': biblicalReference,
      'explanation': explanation,
      'illustration': illustration,
      'application': application,
      'orderIndex': orderIndex,
    };
  }

  factory HomileticBlock.fromJson(Map<String, dynamic> json) {
    return HomileticBlock(
      id: json['id'] as String? ?? UniqueKeyString.generate(),
      title: json['title'] as String? ?? 'Ponto Principal',
      biblicalReference: json['biblicalReference'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      illustration: json['illustration'] as String? ?? '',
      application: json['application'] as String? ?? '',
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }
}

class UniqueKeyString {
  static String generate() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
