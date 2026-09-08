part of 'notes_bloc.dart';

sealed class NotesEvent {
  const NotesEvent();
}

class NotesStarted extends NotesEvent {
  const NotesStarted();
}

class NotesSearchQueryChanged extends NotesEvent {
  const NotesSearchQueryChanged(this.query);

  final String query;
}

class NotesAddRequested extends NotesEvent {
  const NotesAddRequested({required this.title, required this.content});

  final String title;
  final String content;
}

class NotesUpdateRequested extends NotesEvent {
  const NotesUpdateRequested({required this.note, required this.title, required this.content});

  final NoteEntity note;
  final String title;
  final String content;
}

class NotesDeleteRequested extends NotesEvent {
  const NotesDeleteRequested(this.noteId);

  final String noteId;
}

class NotesPinToggled extends NotesEvent {
  const NotesPinToggled(this.noteId);

  final String noteId;
}
