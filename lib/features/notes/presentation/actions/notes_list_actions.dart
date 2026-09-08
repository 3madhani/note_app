import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../screens/note_editor_screen.dart';

abstract final class NotesListActions {
  static void openEditor(BuildContext context, {NoteEntity? note}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)));
  }

  static void togglePin(BuildContext context, NoteEntity note) {
    BlocProvider.of<NotesBloc>(context).add(NotesPinToggled(note.id));
  }

  static Future<void> confirmAndDelete(BuildContext context, NoteEntity note) async {
    final title = note.title.trim().isEmpty ? 'Untitled note' : note.title;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmationDialog(
        title: 'Delete note?',
        message: '“$title” will be removed.',
        confirmLabel: 'Delete',
      ),
    );
    if (shouldDelete != true || !context.mounted) {
      return;
    }

    BlocProvider.of<NotesBloc>(context).add(NotesDeleteRequested(note.id));
  }
}
