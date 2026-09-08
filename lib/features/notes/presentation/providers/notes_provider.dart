import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/toggle_pin_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider(
    this._getNotes,
    this._addNote,
    this._updateNote,
    this._deleteNote,
    this._togglePinNote,
  );

  final GetNotesUseCase _getNotes;
  final AddNoteUseCase _addNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final TogglePinNoteUseCase _togglePinNote;

  List<NoteEntity> _notes = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  UnmodifiableListView<NoteEntity> get notes => UnmodifiableListView(_notes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<NoteEntity> get visibleNotes {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return notes;
    }

    return List.unmodifiable(
      _notes.where(
        (note) =>
            note.title.toLowerCase().contains(normalizedQuery) ||
            note.content.toLowerCase().contains(normalizedQuery),
      ),
    );
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = _sortNotes(await _getNotes());
    } catch (error) {
      _errorMessage = _messageFor(error, 'Unable to load your notes.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) {
      return;
    }
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addNote({required String title, required String content}) async {
    if (!_hasText(title, content)) {
      _errorMessage = 'Add a title or some note content before saving.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final note = NoteEntity(
      id: now.microsecondsSinceEpoch.toRadixString(36),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isPinned: false,
    );

    try {
      _errorMessage = null;
      await _addNote(note);
      _notes = _sortNotes([..._notes, note]);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error, 'Unable to save this note.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote(NoteEntity note, {required String title, required String content}) async {
    if (!_hasText(title, content)) {
      _errorMessage = 'Add a title or some note content before saving.';
      notifyListeners();
      return false;
    }

    final updatedNote = note.copyWith(title: title, content: content, updatedAt: DateTime.now());
    try {
      _errorMessage = null;
      await _updateNote(updatedNote);
      _replaceNote(updatedNote);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error, 'Unable to update this note.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      _errorMessage = null;
      await _deleteNote(noteId);
      _notes = _notes.where((note) => note.id != noteId).toList(growable: false);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error, 'Unable to delete this note.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePinNote(String noteId) async {
    try {
      _errorMessage = null;
      final updatedNote = await _togglePinNote(noteId);
      _replaceNote(updatedNote);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _messageFor(error, 'Unable to update this note.');
      notifyListeners();
      return false;
    }
  }

  void _replaceNote(NoteEntity updatedNote) {
    _notes = _sortNotes(
      _notes.map((note) => note.id == updatedNote.id ? updatedNote : note).toList(),
    );
  }

  bool _hasText(String title, String content) =>
      title.trim().isNotEmpty || content.trim().isNotEmpty;

  List<NoteEntity> _sortNotes(List<NoteEntity> notes) {
    return List<NoteEntity>.of(notes)..sort((first, second) {
      if (first.isPinned != second.isPinned) {
        return first.isPinned ? -1 : 1;
      }
      return second.updatedAt.compareTo(first.updatedAt);
    });
  }

  String _messageFor(Object error, String fallback) {
    final message = error.toString();
    return message.startsWith('AppException: ') ? message.substring(14) : fallback;
  }
}
