import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._localDataSource);

  final NotesLocalDataSource _localDataSource;

  @override
  Future<List<NoteEntity>> getNotes() async {
    return _localDataSource.getNotes().map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<void> addNote(NoteEntity note) => _localDataSource.addNote(NoteModel.fromEntity(note));

  @override
  Future<void> updateNote(NoteEntity note) => _localDataSource.updateNote(NoteModel.fromEntity(note));

  @override
  Future<void> deleteNote(String noteId) => _localDataSource.deleteNote(noteId);

  @override
  Future<void> togglePinNote(String noteId) => _localDataSource.togglePinNote(noteId);
}
