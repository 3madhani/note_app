import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/data/datasources/notes_local_data_source.dart';
import 'features/notes/data/models/note_model.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/usecases/add_note_usecase.dart';
import 'features/notes/domain/usecases/delete_note_usecase.dart';
import 'features/notes/domain/usecases/get_notes_usecase.dart';
import 'features/notes/domain/usecases/toggle_pin_note_usecase.dart';
import 'features/notes/domain/usecases/update_note_usecase.dart';
import 'features/notes/presentation/providers/notes_provider.dart';
import 'features/notes/presentation/screens/notes_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(NoteModelAdapter().typeId)) {
    Hive.registerAdapter(NoteModelAdapter());
  }
  final notesBox = await Hive.openBox<NoteModel>(AppConstants.notesBoxName);
  final localDataSource = NotesLocalDataSource(notesBox);
  final repository = NotesRepositoryImpl(localDataSource);

  runApp(
    NotesApp(
      notesProvider: NotesProvider(
        GetNotesUseCase(repository),
        AddNoteUseCase(repository),
        UpdateNoteUseCase(repository),
        DeleteNoteUseCase(repository),
        TogglePinNoteUseCase(repository),
      )..loadNotes(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  final NotesProvider notesProvider;

  const NotesApp({super.key, required this.notesProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notesProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const NotesListScreen(),
      ),
    );
  }
}
