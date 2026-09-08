import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/notes_provider.dart';
import '../screens/note_editor_screen.dart';

abstract final class NotesListActions {
  static void openEditor(BuildContext context, {NoteEntity? note}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)));
  }

  static Future<void> togglePin(BuildContext context, NoteEntity note) async {
    final provider = context.read<NotesProvider>();
    final saved = await provider.togglePinNote(note.id);
    if (!context.mounted) {
      return;
    }

    AppSnackbar.show(
      context,
      saved ? (note.isPinned ? 'Note unpinned' : 'Note pinned') : provider.errorMessage ?? '',
    );
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

    final provider = context.read<NotesProvider>();
    final deleted = await provider.deleteNote(note.id);
    if (!context.mounted) {
      return;
    }

    AppSnackbar.show(context, deleted ? 'Note deleted' : provider.errorMessage ?? '');
  }
}
