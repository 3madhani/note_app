import '../repositories/notes_repository.dart';

class TogglePinNoteUseCase {
  const TogglePinNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<void> call(String noteId) => _repository.togglePinNote(noteId);
}
