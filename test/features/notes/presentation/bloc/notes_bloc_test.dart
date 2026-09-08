import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/features/notes/domain/entities/note_entity.dart';
import 'package:note_app/features/notes/domain/repositories/notes_repository.dart';
import 'package:note_app/features/notes/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/toggle_pin_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:note_app/features/notes/presentation/bloc/notes_bloc.dart';

void main() {
  group('NotesBloc', () {
    test('loads notes with pinned notes first and newest notes next', () async {
      final older = _note(id: 'older', updatedAt: DateTime.utc(2026, 1, 1));
      final pinned = _note(id: 'pinned', isPinned: true, updatedAt: DateTime.utc(2025, 1, 1));
      final newer = _note(id: 'newer', updatedAt: DateTime.utc(2026, 2, 1));
      final bloc = _bloc(_FakeNotesRepository([older, pinned, newer]));
      final loaded = bloc.stream.firstWhere((state) => !state.isLoading && state.notes.isNotEmpty);

      bloc.add(const NotesStarted());
      final state = await loaded;

      expect(state.notes.map((note) => note.id), ['pinned', 'newer', 'older']);
      await bloc.close();
    });

    test('adds a note and exposes it in the state', () async {
      final repository = _FakeNotesRepository([]);
      final bloc = _bloc(repository);
      final saved = bloc.stream.firstWhere(
        (state) =>
            state.operation == NotesOperation.add &&
            state.operationStatus == NotesOperationStatus.success,
      );

      bloc.add(const NotesAddRequested(title: 'Shopping', content: 'Coffee and bread'));
      final state = await saved;

      expect(repository.notes, hasLength(1));
      expect(state.notes.single.title, 'Shopping');
      await bloc.close();
    });

    test('deletes a saved note', () async {
      final note = _note(id: 'remove-me');
      final bloc = _bloc(_FakeNotesRepository([note]));
      final deleted = bloc.stream.firstWhere(
        (state) =>
            state.operation == NotesOperation.delete &&
            state.operationStatus == NotesOperationStatus.success,
      );

      bloc.add(NotesDeleteRequested(note.id));
      final state = await deleted;

      expect(state.notes, isEmpty);
      await bloc.close();
    });

    test('filters notes by title and content without case sensitivity', () async {
      final bloc = _bloc(
        _FakeNotesRepository([
          _note(id: 'one', title: 'Weekend plans', content: 'Call the florist'),
          _note(id: 'two', title: 'Work', content: 'Prepare the RELEASE notes'),
        ]),
      );
      final loaded = bloc.stream.firstWhere((state) => !state.isLoading && state.notes.length == 2);
      bloc.add(const NotesStarted());
      await loaded;

      final filtered = bloc.stream.firstWhere((state) => state.searchQuery == 'release');
      bloc.add(const NotesSearchQueryChanged('release'));
      final state = await filtered;

      expect(state.visibleNotes.map((note) => note.id), ['two']);
      await bloc.close();
    });
  });
}

NotesBloc _bloc(_FakeNotesRepository repository) {
  return NotesBloc(
    GetNotesUseCase(repository),
    AddNoteUseCase(repository),
    UpdateNoteUseCase(repository),
    DeleteNoteUseCase(repository),
    TogglePinNoteUseCase(repository),
  );
}

NoteEntity _note({
  required String id,
  String title = 'A note',
  String content = 'Some content',
  DateTime? updatedAt,
  bool isPinned = false,
}) {
  final timestamp = updatedAt ?? DateTime.utc(2026, 1, 1);
  return NoteEntity(
    id: id,
    title: title,
    content: content,
    createdAt: timestamp,
    updatedAt: timestamp,
    isPinned: isPinned,
  );
}

class _FakeNotesRepository implements NotesRepository {
  _FakeNotesRepository(List<NoteEntity> notes) : _notes = List.of(notes);

  final List<NoteEntity> _notes;

  List<NoteEntity> get notes => List.unmodifiable(_notes);

  @override
  Future<void> addNote(NoteEntity note) async {
    _notes.add(note);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((note) => note.id == noteId);
  }

  @override
  Future<List<NoteEntity>> getNotes() async => List.of(_notes);

  @override
  Future<NoteEntity> togglePinNote(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    final updatedNote = _notes[index].copyWith(
      isPinned: !_notes[index].isPinned,
      updatedAt: DateTime.utc(2026, 3, 1),
    );
    _notes[index] = updatedNote;
    return updatedNote;
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final index = _notes.indexWhere((savedNote) => savedNote.id == note.id);
    _notes[index] = note;
  }
}
