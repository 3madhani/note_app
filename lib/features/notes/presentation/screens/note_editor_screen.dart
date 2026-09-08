import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_responsive_content.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/note_entity.dart';
import '../actions/note_editor_actions.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/note_editor_form.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  final NoteEntity? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesBloc, NotesState>(
      listenWhen: (previous, current) =>
          previous.operationId != current.operationId &&
          (current.operation == NotesOperation.add || current.operation == NotesOperation.update),
      listener: (context, state) {
        if (state.operationStatus == NotesOperationStatus.success) {
          Navigator.of(context).pop();
          return;
        }
        AppSnackbar.show(context, state.feedbackMessage ?? 'Unable to save this note.');
      },
      buildWhen: (previous, current) => previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit note' : 'New note'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: state.isSubmitting ? null : _save,
                  child: state.isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                      : const Text('Save'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: AppResponsiveContent(
              compactHorizontalPadding: 20,
              wideHorizontalPadding: 32,
              topPadding: 20,
              bottomPadding: 28,
              child: NoteEditorForm(
                titleController: _titleController,
                contentController: _contentController,
                isEditing: _isEditing,
                onSave: state.isSubmitting ? null : _save,
              ),
            ),
          ),
        );
      },
    );
  }

  void _save() {
    NoteEditorActions.save(
      bloc: BlocProvider.of<NotesBloc>(context),
      note: widget.note,
      title: _titleController.text,
      content: _contentController.text,
    );
  }
}
