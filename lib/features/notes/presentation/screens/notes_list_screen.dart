import 'package:flutter/material.dart';

import '../actions/notes_list_actions.dart';
import '../widgets/notes_list_content.dart';
import '../widgets/notes_search_field.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: NotesSearchField()),
        ),
      ),
      body: const NotesListContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NotesListActions.openEditor(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }
}
