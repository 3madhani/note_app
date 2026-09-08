import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notes_provider.dart';

class NotesSearchField extends StatefulWidget {
  const NotesSearchField({super.key});

  @override
  State<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends State<NotesSearchField> {
  late final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      controller: _controller,
      onChanged: (value) {
        context.read<NotesProvider>().setSearchQuery(value);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search notes',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  context.read<NotesProvider>().setSearchQuery('');
                  setState(() {});
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<NotesProvider>().searchQuery);
  }
}
