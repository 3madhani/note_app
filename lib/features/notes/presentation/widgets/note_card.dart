import 'package:flutter/material.dart';

import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = note.title.trim().isEmpty ? 'Untitled note' : note.title;
    final preview = note.content.trim().isEmpty ? 'No additional text' : note.content;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: note.isPinned ? 'Unpin note' : 'Pin note',
                    onPressed: onTogglePin,
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: note.isPinned ? colorScheme.primary : null,
                    ),
                  ),
                  PopupMenuButton<_NoteMenuAction>(
                    tooltip: 'More options',
                    onSelected: (action) {
                      if (action == _NoteMenuAction.delete) {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _NoteMenuAction.delete,
                        child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete')),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              Text(
                _formatUpdatedAt(note.updatedAt),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUpdatedAt(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return 'Updated ${months[local.month - 1]} ${local.day}, $hour:$minute $period';
  }
}

enum _NoteMenuAction { delete }
