import 'package:flutter/material.dart';

class NoteEditorForm extends StatelessWidget {
  const NoteEditorForm({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.isEditing,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isEditing;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          autofocus: !isEditing,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Title', hintText: 'Give your note a title'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: contentController,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              alignLabelWithHint: true,
              labelText: 'Note',
              hintText: 'Start writing…',
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined),
            label: Text(isEditing ? 'Save changes' : 'Save note'),
          ),
        ),
      ],
    );
  }
}
