import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_responsive_content.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/note_entity.dart';
import '../actions/note_editor_actions.dart';
import '../providers/notes_provider.dart';
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
  bool _isSaving = false;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit note' : 'New note'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
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
            isSaving: _isSaving,
            onSave: _isSaving ? null : _save,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final provider = context.read<NotesProvider>();
    final saved = await NoteEditorActions.save(
      provider: provider,
      note: widget.note,
      title: _titleController.text,
      content: _contentController.text,
    );

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    if (saved) {
      Navigator.of(context).pop();
      return;
    }

    AppSnackbar.show(context, provider.errorMessage ?? 'Unable to save this note.');
  }
}
