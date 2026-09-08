import '../../domain/entities/note_entity.dart';
import '../providers/notes_provider.dart';

abstract final class NoteEditorActions {
  static Future<bool> save({
    required NotesProvider provider,
    required NoteEntity? note,
    required String title,
    required String content,
  }) {
    if (note == null) {
      return provider.addNote(title: title, content: content);
    }
    return provider.updateNote(note, title: title, content: content);
  }
}
