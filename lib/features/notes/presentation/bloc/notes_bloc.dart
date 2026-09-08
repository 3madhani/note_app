import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_exception.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/toggle_pin_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._getNotes, this._addNote, this._updateNote, this._deleteNote, this._togglePinNote)
    : super(const NotesState()) {
    on<NotesStarted>(_onStarted);
    on<NotesSearchQueryChanged>(_onSearchQueryChanged);
    on<NotesAddRequested>(_onAddRequested);
    on<NotesUpdateRequested>(_onUpdateRequested);
    on<NotesDeleteRequested>(_onDeleteRequested);
    on<NotesPinToggled>(_onPinToggled);
  }

  final GetNotesUseCase _getNotes;
  final AddNoteUseCase _addNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final TogglePinNoteUseCase _togglePinNote;

  Future<void> _onStarted(NotesStarted event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    try {
      emit(state.copyWith(notes: _sortNotes(await _getNotes()), isLoading: false));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFor(error, 'Unable to load your notes.'),
        ),
      );
    }
  }

  void _onSearchQueryChanged(NotesSearchQueryChanged event, Emitter<NotesState> emit) {
    if (event.query != state.searchQuery) {
      emit(state.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onAddRequested(NotesAddRequested event, Emitter<NotesState> emit) async {
    if (!_hasText(event.title, event.content)) {
      _emitFailure(emit, NotesOperation.add, 'Add a title or some note content before saving.');
      return;
    }

    final now = DateTime.now();
    final note = NoteEntity(
      id: now.microsecondsSinceEpoch.toRadixString(36),
      title: event.title,
      content: event.content,
      createdAt: now,
      updatedAt: now,
      isPinned: false,
    );
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    try {
      await _addNote(note);
      emit(
        state.copyWith(
          notes: _sortNotes([...state.notes, note]),
          isSubmitting: false,
          operation: NotesOperation.add,
          operationStatus: NotesOperationStatus.success,
          operationId: state.operationId + 1,
          feedbackMessage: 'Note saved',
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _emitFailure(emit, NotesOperation.add, _messageFor(error, 'Unable to save this note.'));
    }
  }

  Future<void> _onUpdateRequested(NotesUpdateRequested event, Emitter<NotesState> emit) async {
    if (!_hasText(event.title, event.content)) {
      _emitFailure(emit, NotesOperation.update, 'Add a title or some note content before saving.');
      return;
    }

    final updatedNote = event.note.copyWith(
      title: event.title,
      content: event.content,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    try {
      await _updateNote(updatedNote);
      final notes = state.notes
          .map((note) => note.id == updatedNote.id ? updatedNote : note)
          .toList(growable: false);
      emit(
        state.copyWith(
          notes: _sortNotes(notes),
          isSubmitting: false,
          operation: NotesOperation.update,
          operationStatus: NotesOperationStatus.success,
          operationId: state.operationId + 1,
          feedbackMessage: 'Changes saved',
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _emitFailure(emit, NotesOperation.update, _messageFor(error, 'Unable to update this note.'));
    }
  }

  Future<void> _onDeleteRequested(NotesDeleteRequested event, Emitter<NotesState> emit) async {
    try {
      await _deleteNote(event.noteId);
      emit(
        state.copyWith(
          notes: state.notes.where((note) => note.id != event.noteId).toList(growable: false),
          operation: NotesOperation.delete,
          operationStatus: NotesOperationStatus.success,
          operationId: state.operationId + 1,
          feedbackMessage: 'Note deleted',
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _emitFailure(emit, NotesOperation.delete, _messageFor(error, 'Unable to delete this note.'));
    }
  }

  Future<void> _onPinToggled(NotesPinToggled event, Emitter<NotesState> emit) async {
    try {
      final updatedNote = await _togglePinNote(event.noteId);
      final notes = state.notes
          .map((note) => note.id == updatedNote.id ? updatedNote : note)
          .toList(growable: false);
      emit(
        state.copyWith(
          notes: _sortNotes(notes),
          operation: NotesOperation.togglePin,
          operationStatus: NotesOperationStatus.success,
          operationId: state.operationId + 1,
          feedbackMessage: updatedNote.isPinned ? 'Note pinned' : 'Note unpinned',
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _emitFailure(
        emit,
        NotesOperation.togglePin,
        _messageFor(error, 'Unable to update this note.'),
      );
    }
  }

  void _emitFailure(Emitter<NotesState> emit, NotesOperation operation, String message) {
    emit(
      state.copyWith(
        isSubmitting: false,
        errorMessage: message,
        feedbackMessage: message,
        operation: operation,
        operationStatus: NotesOperationStatus.failure,
        operationId: state.operationId + 1,
      ),
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
    return error is AppException ? error.message : fallback;
  }
}
