import 'sermon_block.dart';

class Sermon {
  final String id;
  final String userId;
  final String title;
  final String biblicalReference;
  final String category;
  final String sermonType; // Expositivo, Temático, Textual, etc.
  final String introduction;
  final List<HomileticBlock> blocks;
  final String conclusion;
  final String appeal;
  final bool isFavorite;
  final String status; // 'draft', 'ready', 'archived'
  final int preachCount;
  final DateTime? lastPreachedAt;
  final int estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sermon({
    required this.id,
    required this.userId,
    required this.title,
    required this.biblicalReference,
    this.category = 'Geral',
    this.sermonType = 'Expositivo',
    this.introduction = '',
    this.blocks = const [],
    this.conclusion = '',
    this.appeal = '',
    this.isFavorite = false,
    this.status = 'draft',
    this.preachCount = 0,
    this.lastPreachedAt,
    this.estimatedDurationMinutes = 40,
    required this.createdAt,
    required this.updatedAt,
  });

  Sermon copyWith({
    String? id,
    String? userId,
    String? title,
    String? biblicalReference,
    String? category,
    String? sermonType,
    String? introduction,
    List<HomileticBlock>? blocks,
    String? conclusion,
    String? appeal,
    bool? isFavorite,
    String? status,
    int? preachCount,
    DateTime? lastPreachedAt,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sermon(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      biblicalReference: biblicalReference ?? this.biblicalReference,
      category: category ?? this.category,
      sermonType: sermonType ?? this.sermonType,
      introduction: introduction ?? this.introduction,
      blocks: blocks ?? this.blocks,
      conclusion: conclusion ?? this.conclusion,
      appeal: appeal ?? this.appeal,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      preachCount: preachCount ?? this.preachCount,
      lastPreachedAt: lastPreachedAt ?? this.lastPreachedAt,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'biblical_reference': biblicalReference,
      'category': category,
      'sermon_type': sermonType,
      'content': {
        'introduction': introduction,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'conclusion': conclusion,
        'appeal': appeal,
      },
      'is_favorite': isFavorite,
      'status': status,
      'preach_count': preachCount,
      'last_preached_at': lastPreachedAt?.toIso8601String(),
      'estimated_duration_minutes': estimatedDurationMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Sermon.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>? ?? {};
    final rawBlocks = content['blocks'] as List<dynamic>? ?? [];

    return Sermon(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sem Título',
      biblicalReference: json['biblical_reference'] as String? ?? '',
      category: json['category'] as String? ?? 'Geral',
      sermonType: json['sermon_type'] as String? ?? 'Expositivo',
      introduction: content['introduction'] as String? ?? '',
      blocks: rawBlocks
          .map((b) => HomileticBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      conclusion: content['conclusion'] as String? ?? '',
      appeal: content['appeal'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      status: json['status'] as String? ?? 'draft',
      preachCount: json['preach_count'] as int? ?? 0,
      lastPreachedAt: json['last_preached_at'] != null
          ? DateTime.tryParse(json['last_preached_at'] as String)
          : null,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int? ?? 40,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  /// Gera representação limpa em Markdown para renderização no Púlpito ou Impressão
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln('**Texto Base:** $biblicalReference  |  **Tipo:** $sermonType  |  **Categoria:** $category\n');
    buffer.writeln('---\n');

    if (introduction.isNotEmpty) {
      buffer.writeln('### 📖 Introdução');
      buffer.writeln('$introduction\n');
    }

    for (var i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      buffer.writeln('### ${b.title.isNotEmpty ? b.title : 'Ponto ${i + 1}'}');
      if (b.biblicalReference.isNotEmpty) {
        buffer.writeln('> *${b.biblicalReference}*\n');
      }
      if (b.explanation.isNotEmpty) {
        buffer.writeln('**Explanação Teológica:**');
        buffer.writeln('${b.explanation}\n');
      }
      if (b.illustration.isNotEmpty) {
        buffer.writeln('💡 **Ilustração Prática:**');
        buffer.writeln('${b.illustration}\n');
      }
      if (b.application.isNotEmpty) {
        buffer.writeln('🎯 **Aplicação para a Vida:**');
        buffer.writeln('${b.application}\n');
      }
      buffer.writeln('---\n');
    }

    if (conclusion.isNotEmpty) {
      buffer.writeln('### 🏁 Conclusão');
      buffer.writeln('$conclusion\n');
    }

    if (appeal.isNotEmpty) {
      buffer.writeln('### 🔥 Apelo & Convocação');
      buffer.writeln('$appeal\n');
    }

    return buffer.toString();
  }
}
