import 'package:hive/hive.dart';

import '../../../../core/utils/app_exception.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  const NotesLocalDataSource(this._notesBox);

  final Box<NoteModel> _notesBox;

  List<NoteModel> getNotes() {
    try {
      return _notesBox.values.toList(growable: false);
    } catch (error) {
      throw AppException('Unable to load your notes.', error);
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _notesBox.put(note.id, note);
    } catch (error) {
      throw AppException('Unable to save this note.', error);
    }
  }

  Future<void> updateNote(NoteModel note) => addNote(note);

  Future<void> deleteNote(String noteId) async {
    try {
      await _notesBox.delete(noteId);
    } catch (error) {
      throw AppException('Unable to delete this note.', error);
    }
  }

  Future<void> togglePinNote(String noteId) async {
    try {
      final note = _notesBox.get(noteId);
      if (note == null) {
        throw const AppException('This note could not be found.');
      }
      await _notesBox.put(
        noteId,
        note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()),
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException('Unable to update this note.', error);
    }
  }
}
