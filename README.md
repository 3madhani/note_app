# Notes

An offline-first Flutter notes app built with Material 3, BLoC, and Hive. It supports creating, editing, deleting, searching, and pinning notes; all data remains on the device.

## Architecture

The notes feature follows a lightweight Clean Architecture dependency direction:

`presentation → domain ← data`

- `domain` contains the framework-independent note entity, repository contract, and one use case per action.
- `data` owns the Hive model, generated adapter, local data source, and repository implementation.
- `presentation` contains `NotesBloc`, events, states, screens, and reusable widgets. Widgets dispatch BLoC events and never access Hive directly.
- The Provider package and `NotesProvider` remain in the codebase for compatibility, but BLoC is the active presentation state manager.

## Folder structure

```text
lib/
  core/{constants,theme,utils,widgets}/
  features/notes/
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/{actions,bloc,providers,screens,widgets}/
```

## Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Run the tests and static analysis with:

```bash
flutter test
flutter analyze
```

## Hive adapter generation

Whenever `NoteModel` changes, regenerate its Hive adapter:

```bash
dart run build_runner build --delete-conflicting-outputs
```
