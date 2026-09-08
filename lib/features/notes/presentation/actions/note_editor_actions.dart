import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';

abstract final class NoteEditorActions {
  static void save({
    required NotesBloc bloc,
    required NoteEntity? note,
    required String title,
    required String content,
  }) {
    if (note == null) {
      bloc.add(NotesAddRequested(title: title, content: content));
      return;
    }
    bloc.add(NotesUpdateRequested(note: note, title: title, content: content));
  }
}
