part of 'notes_bloc.dart';

enum NotesOperation { none, add, update, delete, togglePin }

enum NotesOperationStatus { idle, success, failure }

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.searchQuery = '',
    this.operation = NotesOperation.none,
    this.operationStatus = NotesOperationStatus.idle,
    this.operationId = 0,
    this.feedbackMessage,
  });

  final List<NoteEntity> notes;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String searchQuery;
  final NotesOperation operation;
  final NotesOperationStatus operationStatus;
  final int operationId;
  final String? feedbackMessage;

  List<NoteEntity> get visibleNotes {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List.unmodifiable(notes);
    }

    return List.unmodifiable(
      notes.where(
        (note) =>
            note.title.toLowerCase().contains(normalizedQuery) ||
            note.content.toLowerCase().contains(normalizedQuery),
      ),
    );
  }

  NotesState copyWith({
    List<NoteEntity>? notes,
    bool? isLoading,
    bool? isSubmitting,
    String? searchQuery,
    NotesOperation? operation,
    NotesOperationStatus? operationStatus,
    int? operationId,
    String? errorMessage,
    String? feedbackMessage,
    bool clearErrorMessage = false,
    bool clearFeedbackMessage = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      operation: operation ?? this.operation,
      operationStatus: operationStatus ?? this.operationStatus,
      operationId: operationId ?? this.operationId,
      feedbackMessage: clearFeedbackMessage ? null : feedbackMessage ?? this.feedbackMessage,
    );
  }
}
