import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/data/datasources/notes_local_data_source.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/usecases/add_note_usecase.dart';
import 'features/notes/domain/usecases/delete_note_usecase.dart';
import 'features/notes/domain/usecases/get_notes_usecase.dart';
import 'features/notes/domain/usecases/toggle_pin_note_usecase.dart';
import 'features/notes/domain/usecases/update_note_usecase.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/screens/notes_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localDataSource = await NotesLocalDataSource.create();
  final repository = NotesRepositoryImpl(localDataSource);

  runApp(
    NotesApp(
      getNotes: GetNotesUseCase(repository),
      addNote: AddNoteUseCase(repository),
      updateNote: UpdateNoteUseCase(repository),
      deleteNote: DeleteNoteUseCase(repository),
      togglePinNote: TogglePinNoteUseCase(repository),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({
    super.key,
    required this.getNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.togglePinNote,
  });

  final GetNotesUseCase getNotes;
  final AddNoteUseCase addNote;
  final UpdateNoteUseCase updateNote;
  final DeleteNoteUseCase deleteNote;
  final TogglePinNoteUseCase togglePinNote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) =>
          NotesBloc(getNotes, addNote, updateNote, deleteNote, togglePinNote)
            ..add(const NotesStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const NotesListScreen(),
      ),
    );
  }
}
