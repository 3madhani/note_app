import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<void> call(String noteId) => _repository.deleteNote(noteId);
}
