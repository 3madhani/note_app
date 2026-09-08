import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_responsive_content.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/note_entity.dart';
import '../actions/notes_list_actions.dart';
import '../bloc/notes_bloc.dart';
import 'note_card.dart';

class NotesListContent extends StatelessWidget {
  const NotesListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listenWhen: (previous, current) =>
          previous.operationId != current.operationId &&
          (current.operation == NotesOperation.delete ||
              current.operation == NotesOperation.togglePin),
      listener: (context, state) {
        AppSnackbar.show(context, state.feedbackMessage ?? 'Unable to update this note.');
      },
      child: BlocSelector<NotesBloc, NotesState, bool>(
        selector: (state) => state.isLoading,
        builder: (context, isLoading) {
          if (isLoading) {
            return const AppLoadingView(label: 'Loading notes');
          }
          return const _NotesResults();
        },
      ),
    );
  }
}

class _NotesResults extends StatelessWidget {
  const _NotesResults();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotesBloc, NotesState, _NotesListViewData>(
      selector: (state) =>
          _NotesListViewData(notes: state.visibleNotes, searchQuery: state.searchQuery),
      builder: (context, data) {
        if (data.notes.isEmpty) {
          return AppEmptyState(
            icon: data.isSearching ? Icons.search_off_outlined : Icons.sticky_note_2_outlined,
            title: data.isSearching ? 'No matching notes' : 'Your notes will appear here',
            message: data.isSearching
                ? 'Try a different word or phrase.'
                : 'Capture an idea, a task, or anything worth remembering.',
          );
        }

        return AppResponsiveContent(
          topPadding: 12,
          bottomPadding: 100,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: data.notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = data.notes[index];
              return NoteCard(
                note: note,
                onTap: () => NotesListActions.openEditor(context, note: note),
                onTogglePin: () => NotesListActions.togglePin(context, note),
                onDelete: () => NotesListActions.confirmAndDelete(context, note),
              );
            },
          ),
        );
      },
    );
  }
}

class _NotesListViewData {
  const _NotesListViewData({required this.notes, required this.searchQuery});

  final List<NoteEntity> notes;
  final String searchQuery;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is _NotesListViewData &&
        listEquals(other.notes, notes) &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), searchQuery);
}
