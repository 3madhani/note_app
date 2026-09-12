import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_exception.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  const NotesLocalDataSource(this._database);

  static const _notesTable = 'notes';

  final Database _database;

  static Future<NotesLocalDataSource> create() async {
    final databaseDirectory = await getDatabasesPath();
    final database = await openDatabase(
      join(databaseDirectory, AppConstants.notesDatabaseName),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_notesTable(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            is_pinned INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return NotesLocalDataSource(database);
  }

  Future<List<NoteModel>> getNotes() async {
    try {
      final notes = await _database.query(
        _notesTable,
        orderBy: 'is_pinned DESC, updated_at DESC',
      );
      return notes.map(NoteModel.fromMap).toList(growable: false);
    } catch (error) {
      throw AppException('Unable to load your notes.', error);
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _database.insert(_notesTable, note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (error) {
      throw AppException('Unable to save this note.', error);
    }
  }

  Future<void> updateNote(NoteModel note) => addNote(note);

  Future<void> deleteNote(String noteId) async {
    try {
      await _database.delete(_notesTable, where: 'id = ?', whereArgs: [noteId]);
    } catch (error) {
      throw AppException('Unable to delete this note.', error);
    }
  }

  Future<NoteModel> togglePinNote(String noteId) async {
    try {
      return await _database.transaction<NoteModel>((transaction) async {
        final notes = await transaction.query(
          _notesTable,
          where: 'id = ?',
          whereArgs: [noteId],
          limit: 1,
        );
        if (notes.isEmpty) {
          throw const AppException('This note could not be found.');
        }

        final note = NoteModel.fromMap(notes.single);
        final updatedNote = note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now());
        await transaction.update(
          _notesTable,
          updatedNote.toMap(),
          where: 'id = ?',
          whereArgs: [noteId],
        );
        return updatedNote;
      });
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException('Unable to update this note.', error);
    }
  }
}
