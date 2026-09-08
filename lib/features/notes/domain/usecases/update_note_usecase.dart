import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<void> call(NoteEntity note) => _repository.updateNote(note);
}
