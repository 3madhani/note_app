import '../repositories/notes_repository.dart';
import '../entities/note_entity.dart';

class TogglePinNoteUseCase {
  const TogglePinNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<NoteEntity> call(String noteId) => _repository.togglePinNote(noteId);
}
