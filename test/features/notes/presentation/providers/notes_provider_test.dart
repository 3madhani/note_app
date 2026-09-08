import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/features/notes/domain/entities/note_entity.dart';
import 'package:note_app/features/notes/domain/repositories/notes_repository.dart';
import 'package:note_app/features/notes/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/toggle_pin_note_usecase.dart';
import 'package:note_app/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:note_app/features/notes/presentation/providers/notes_provider.dart';

void main() {
  group('NotesProvider', () {
    test('loads notes with pinned notes first and newest notes next', () async {
      final older = _note(id: 'older', updatedAt: DateTime.utc(2026, 1, 1));
      final pinned = _note(id: 'pinned', isPinned: true, updatedAt: DateTime.utc(2025, 1, 1));
      final newer = _note(id: 'newer', updatedAt: DateTime.utc(2026, 2, 1));
      final provider = _provider(_FakeNotesRepository([older, pinned, newer]));

      await provider.loadNotes();

      expect(provider.isLoading, isFalse);
      expect(provider.notes.map((note) => note.id), ['pinned', 'newer', 'older']);
    });

    test('adds a note and exposes it in the notes list', () async {
      final repository = _FakeNotesRepository([]);
      final provider = _provider(repository);

      final saved = await provider.addNote(title: 'Shopping', content: 'Coffee and bread');

      expect(saved, isTrue);
      expect(repository.notes, hasLength(1));
      expect(provider.notes.single.title, 'Shopping');
    });

    test('deletes a saved note', () async {
      final note = _note(id: 'remove-me');
      final provider = _provider(_FakeNotesRepository([note]));
      await provider.loadNotes();

      final deleted = await provider.deleteNote(note.id);

      expect(deleted, isTrue);
      expect(provider.notes, isEmpty);
    });

    test('filters notes by title and content without case sensitivity', () async {
      final provider = _provider(
        _FakeNotesRepository([
          _note(id: 'one', title: 'Weekend plans', content: 'Call the florist'),
          _note(id: 'two', title: 'Work', content: 'Prepare the RELEASE notes'),
        ]),
      );
      await provider.loadNotes();

      provider.setSearchQuery('release');

      expect(provider.visibleNotes.map((note) => note.id), ['two']);
    });
  });
}

NotesProvider _provider(_FakeNotesRepository repository) {
  return NotesProvider(
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
