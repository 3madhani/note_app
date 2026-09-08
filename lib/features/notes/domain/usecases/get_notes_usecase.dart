import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class GetNotesUseCase {
  const GetNotesUseCase(this._repository);

  final NotesRepository _repository;

  Future<List<NoteEntity>> call() => _repository.getNotes();
}
