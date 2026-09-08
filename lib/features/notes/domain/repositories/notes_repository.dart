import '../entities/note_entity.dart';

abstract interface class NotesRepository {
  Future<List<NoteEntity>> getNotes();

  Future<void> addNote(NoteEntity note);

  Future<void> updateNote(NoteEntity note);

  Future<void> deleteNote(String noteId);

  Future<void> togglePinNote(String noteId);
}
