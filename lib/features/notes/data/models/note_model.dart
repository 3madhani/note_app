import '../../domain/entities/note_entity.dart';

class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
  });

  final String id;

  final String title;

  final String content;

  final DateTime createdAt;

  final DateTime updatedAt;

  final bool isPinned;

  factory NoteModel.fromEntity(NoteEntity note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isPinned: note.isPinned,
    );
  }

  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
    );
  }

  factory NoteModel.fromMap(Map<String, Object?> map) {
    return NoteModel(
      id: map['id']! as String,
      title: map['title']! as String,
      content: map['content']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']! as int),
      isPinned: (map['is_pinned']! as int) == 1,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  NoteModel copyWith({bool? isPinned, DateTime? updatedAt}) {
    return NoteModel(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
