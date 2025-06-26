# Project tree
```markdown
. 📂 lib
└── 📂 core/
│  └── 📂 bloc/
│    └── 📂 bottomnavbar/
│      ├── 📄 navigation_bloc.dart
│    └── 📂 oserver/
│      ├── 📄 bloc_observer.dart
│    └── 📂 video_bloc/
│      ├── 📄 video_bloc.dart
│      ├── 📄 video_event.dart
│      ├── 📄 video_state.dart
│  └── 📂 constants/
│    ├── 📄 app_constants.dart
│    ├── 📄 color_constants.dart
│    ├── 📄 text_constants.dart
│  └── 📂 errors/
│    ├── 📄 exceptions.dart
│    ├── 📄 failures.dart
│  └── 📂 localization/
│    ├── 📄 app_localizations.dart
│    └── 📂 language_bloc/
│      ├── 📄 language_bloc.dart
│    └── 📂 translations/
│      ├── 📄 ar.dart
│      ├── 📄 en.dart
│  └── 📂 network/
│    ├── 📄 api_client.dart
│    ├── 📄 network_info.dart
│  └── 📂 routes/
│    ├── 📄 app_routes.dart
│  └── 📂 services/
│    ├── 📄 notification_services.dart
│  └── 📂 theme/
│    ├── 📄 app_theme.dart
│    ├── 📄 theme_cubit.dart
│  └── 📂 usecases/
│    ├── 📄 usecase.dart
│  └── 📂 utils/
│    ├── 📄 date_picker_utills.dart
│    ├── 📄 dialog.dart
│    ├── 📄 snackbar_utils.dart
│    ├── 📄 string_utils.dart
│  └── 📂 widgets/
│    ├── 📄 app_scaffold.dart
│    ├── 📄 bottomnavitem.dart
│    ├── 📄 cusrom_glass_snackbar.dart
│    ├── 📄 custom_bottom_navigationbar.dart
│    ├── 📄 custom_button.dart
│    ├── 📄 custom_checkbox.dart
│    ├── 📄 custom_date_time_picker.dart
│    ├── 📄 custom_dialog.dart
│    ├── 📄 custom_drawer.dart
│    ├── 📄 custom_dropdown.dart
│    ├── 📄 custom_icon.dart
│    ├── 📄 custom_input.dart
│    ├── 📄 custom_linear_progress_indecator.dart
│    ├── 📄 custom_siwtch.dart
│    ├── 📄 custom_slider.dart
│    ├── 📄 custom_text.dart
│    ├── 📄 duration_picker.dart
│    ├── 📄 loading_indicator.dart
│    ├── 📄 videoplayer.dart
└── 📂 di/
│  ├── 📄 injection_container.dart
└── 📂 features/
│  └── 📂 notes/
│    └── 📂 data/
│      └── 📂 datasource/
│        ├── 📄 note_local_data_source.dart
│        ├── 📄 note_local_data_source_impl.dart
│      └── 📂 models/
│        ├── 📄 note_model.dart
│        ├── 📄 note_model.g.dart
│      └── 📂 repository/
│        ├── 📄 note_repository_impl.dart
│    └── 📂 domain/
│      └── 📂 entities/
│        ├── 📄 note_entity.dart
│      └── 📂 repository/
│        ├── 📄 note_repository.dart
│      └── 📂 usecases/
│        ├── 📄 create_note.dart
│        ├── 📄 delete_note.dart
│        ├── 📄 get_note_by_id.dart
│        ├── 📄 get_notes.dart
│        ├── 📄 notes_usecase.dart
│        ├── 📄 search_notes.dart
│        ├── 📄 update_note.dart
│    └── 📂 presentation/
│      └── 📂 bloc/
│        ├── 📄 notes_bloc.dart
│        ├── 📄 notes_events.dart
│        ├── 📄 notes_states.dart
│      └── 📂 pages/
│        ├── 📄 add_notes_page.dart
│        ├── 📄 note_view.dart
│        ├── 📄 notes_page.dart
│      └── 📂 widgets/
│        ├── 📄 color_picker_widget.dart
│        ├── 📄 note_card.dart
└── 📄 main.dart
```

# data layer

```dart
lib\features\notes\data\repository\note_repository_impl.dart:
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repository/note_repository.dart';
import '../datasource/note_local_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  // If you had a remote data source, you would add it here:
  // final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({
    required this.localDataSource,
    // required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, NoteEntity>> createNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final createdNote = await localDataSource.createNote(noteModel);
      return Right(createdNote.toEntity());
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) async {
    try {
      await localDataSource.deleteNote(id);
      return const Right(null); // Indicate success with void
    } on NotFoundException {
      return const Left(NotFoundFailure(message: 'Note not found.'));
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> getNoteById(String id) async {
    try {
      final noteModel = await localDataSource.getNoteById(id);
      return Right(noteModel.toEntity());
    } on NotFoundException {
      return const Left(NotFoundFailure(message: 'Note not found.'));
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> getNotes() async {
    try {
      final noteModels = await localDataSource.getNotes();
      return Right(noteModels.map((model) => model.toEntity()).toList());
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> searchNotes(String query) async {
    try {
      final noteModels = await localDataSource.searchNotes(query);
      return Right(noteModels.map((model) => model.toEntity()).toList());
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      final updatedNote = await localDataSource.updateNote(noteModel);
      return Right(updatedNote.toEntity());
    } on NotFoundException {
      return const Left(NotFoundFailure(message: 'Note not found for update.'));
    } on DatabaseException {
      return const Left(DatabaseFailure());
    } on Exception {
      return const Left(GenericFailure());
    }
  }
}

lib\features\notes\data\models\note_model.dart:
import 'package:isar/isar.dart';
import '../../domain/entities/note_entity.dart'; // Import the domain entity

// This part directive is crucial for Isar code generation.
// Make sure the filename matches: 'note_model.g.dart' for 'note_model.dart'
part 'note_model.g.dart';

@Collection()
class NoteModel {
  Id isarId = Isar.autoIncrement; // Internal Isar ID

  @Index(unique: true) // Ensure the 'id' from NoteEntity is unique
  late String id; // This will store the NoteEntity's unique string ID

  late String title;
  late String content;
  late DateTime createdAt;
  DateTime? updatedAt;
  bool isPinned;
  int? color; // Stored as an integer (e.g., ARGB value)
  List<String>? tags; // Isar supports List<String> directly
  late int? order; // NEW: Add order field

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags,
    this.order, // NEW: Add order to constructor
  });

  /// Factory constructor to create a [NoteModel] from a [NoteEntity].
  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
      color: entity.color,
      tags: entity.tags,
      order: entity.order, // NEW: Assign order from entity
    );
  }

  /// Converts this [NoteModel] to a [NoteEntity].
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      color: color,
      tags: tags,
      order: order, // NEW: Assign order to entity
    );
  }
}


lib\features\notes\data\datasource\note_local_data_source.dart:
import '../models/note_model.dart';

/// Abstract class defining the contract for local data operations on Notes.
abstract class NoteLocalDataSource {
  /// Creates a new note in the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<NoteModel> createNote(NoteModel note);

  /// Retrieves all notes from the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotes();

  /// Retrieves a single note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> getNoteById(String id);

  /// Updates an existing note in the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> updateNote(NoteModel note);

  /// Deletes a note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<void> deleteNote(String id);

  /// Searches for notes in the local database based on a query string.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> searchNotes(String query);
}

lib\features\notes\data\datasource\note_local_data_source_impl.dart:
import 'package:isar/isar.dart';

import '../../../../core/errors/exceptions.dart'; // Import custom exceptions
import '../models/note_model.dart';
import 'note_local_data_source.dart';

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Isar isar;

  NoteLocalDataSourceImpl({required this.isar});

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      await isar.writeTxn(() async {
        await isar.noteModels.put(note); // Insert or update the note
      });
      return note;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await isar.writeTxn(() async {
        final success = await isar.noteModels.filter().idEqualTo(id).deleteFirst();
        if (!success) {
          throw NotFoundException(); // Note not found to delete
        }
      });
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException();
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final note = await isar.noteModels.filter().idEqualTo(id).findFirst();
      if (note == null) {
        throw NotFoundException(); // Or a more specific exception if needed
      }
      return note;
    } catch (e) {
      if (e is NotFoundException) rethrow; // Re-throw if it's our specific exception
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final notes = await isar.noteModels.where().findAll();

      // Sort notes: pinned notes first (sorted by order), then unpinned notes (sorted by order)
      notes.sort((a, b) {
        // Sort by order first, then by pinned status
        final aOrder = a.order ?? 0;
        final bOrder = b.order ?? 0;
        if (aOrder != bOrder) {
          return aOrder.compareTo(bOrder);
        }
        // If order is the same, sort by pinned status (pinned notes come first)
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final notes = await isar.noteModels
          .filter()
          .titleContains(query, caseSensitive: false)
          .or()
          .contentContains(query, caseSensitive: false)
          .findAll();
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      // Check if the note exists before updating
      final existingNote = await isar.noteModels.filter().idEqualTo(note.id).findFirst();
      if (existingNote == null) {
        throw NotFoundException();
      }

      // Isar's put method will update if the unique index 'id' matches
      await isar.writeTxn(() async {
        // We need to ensure the isarId is correct for update,
        // if we are using the NoteModel's 'id' as the unique index.
        // If 'id' is unique, Isar will find and update it.
        // If we are relying on isarId, we need to retrieve the existing one.
        // Given our NoteModel uses `id` with `@Index(unique: true)`, `put` will work.
        note.isarId = existingNote.isarId; // Ensure we update the correct Isar object
        await isar.noteModels.put(note);
      });
      return note;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException();
    }
  }
}


```

# domain layer

```dart
lib\features\notes\domain\entities\note_entity.dart:
import 'package:equatable/equatable.dart';

/// Represents a Note entity in the domain layer.
/// This entity is pure and does not depend on any framework or database specifics.
class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final int? color; // Represents a color value, e.g., ARGB integer
  final List<String>? tags;
  final int? order; // NEW: Add order field

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags,
    this.order, // NEW: Add order to constructor
  });

  /// Creates a copy of this NoteEntity with the given fields replaced with the new values.
  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? color,
    List<String>? tags,
    int? order, // NEW: Add order to copyWith
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      order: order ?? this.order, // NEW: Assign order
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        createdAt,
        updatedAt,
        isPinned,
        color,
        tags,
        order, // NEW: Add order to props
      ];
}

lib\features\notes\domain\repository\note_repository.dart:
import 'package:dartz/dartz.dart'; // For Either
import '../../../../core/errors/failures.dart'; // Import the Failure definitions
import '../entities/note_entity.dart'; // Import the NoteEntity

/// Abstract class defining the contract for Note operations in the domain layer.
/// This interface specifies what operations can be performed on Note entities,
/// without specifying how these operations are implemented (e.g., from a database or API).
abstract class NoteRepository {
  /// Creates a new note.
  /// Returns [Right] with [NoteEntity] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, NoteEntity>> createNote(NoteEntity note);

  /// Retrieves a list of all notes.
  /// Returns [Right] with a [List<NoteEntity>] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, List<NoteEntity>>> getNotes();

  /// Retrieves a single note by its ID.
  /// Returns [Right] with [NoteEntity] if found, or [Left] with [Failure] (e.g., NotFoundFailure) on error.
  Future<Either<Failure, NoteEntity>> getNoteById(String id);

  /// Updates an existing note.
  /// Returns [Right] with [NoteEntity] (the updated note) if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, NoteEntity>> updateNote(NoteEntity note);

  /// Deletes a note by its ID.
  /// Returns [Right] with [void] (indicating success) if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, void>> deleteNote(String id);

  /// Searches for notes based on a query string.
  /// Returns [Right] with a [List<NoteEntity>] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, List<NoteEntity>>> searchNotes(String query);
}
lib\features\notes\domain\usecases\create_note.dart:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/note_entity.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class CreateNote implements NotesUseCase<NoteEntity, CreateNoteParams> {
  final NoteRepository repository;

  CreateNote(this.repository);

  @override
  Future<Either<Failure, NoteEntity>> call(CreateNoteParams params) async {
    return await repository.createNote(params.note);
  }
}

class CreateNoteParams extends Equatable {
  final NoteEntity note;

  const CreateNoteParams({required this.note});

  @override
  List<Object> get props => [note];
}

lib\features\notes\domain\usecases\delete_note.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class DeleteNote implements NotesUseCase<void, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams({required this.id});

  @override
  List<Object> get props => [id];
}

lib\features\notes\domain\usecases\get_note_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/note_entity.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class GetNoteById implements NotesUseCase<NoteEntity, GetNoteByIdParams> {
  final NoteRepository repository;

  GetNoteById(this.repository);

  @override
  Future<Either<Failure, NoteEntity>> call(GetNoteByIdParams params) async {
    return await repository.getNoteById(params.id);
  }
}

class GetNoteByIdParams extends Equatable {
  final String id;

  const GetNoteByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}

lib\features\notes\domain\usecases\get_notes.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart'; // For NoParams
import '../entities/note_entity.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class GetNotes implements NotesUseCase<List<NoteEntity>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<NoteEntity>>> call(NoParams params) async {
    return await repository.getNotes();
  }
}

lib\features\notes\domain\usecases\notes_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

/// Abstract class for a Use Case specific to the Notes feature.
/// This Use Case returns an [Either] type, explicitly handling success or failure.
/// [Type] represents the return type on success.
/// [Params] represents the parameters required by the use case.
abstract class NotesUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// A class to be used when a Notes Use Case does not require any parameters.
/// This can extend the global NoParams if it's compatible, or be a separate one.
/// For simplicity, we'll use the global NoParams as it's just a marker.
// class NotesNoParams extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

lib\features\notes\domain\usecases\search_notes.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/note_entity.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class SearchNotes implements NotesUseCase<List<NoteEntity>, SearchNotesParams> {
  final NoteRepository repository;

  SearchNotes(this.repository);

  @override
  Future<Either<Failure, List<NoteEntity>>> call(SearchNotesParams params) async {
    return await repository.searchNotes(params.query);
  }
}

class SearchNotesParams extends Equatable {
  final String query;

  const SearchNotesParams({required this.query});

  @override
  List<Object> get props => [query];
}

lib\features\notes\domain\usecases\update_note.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/note_entity.dart';
import '../repository/note_repository.dart';
import 'notes_usecase.dart'; // Import the new NotesUseCase

class UpdateNote implements NotesUseCase<NoteEntity, UpdateNoteParams> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, NoteEntity>> call(UpdateNoteParams params) async {
    return await repository.updateNote(params.note);
  }
}

class UpdateNoteParams extends Equatable {
  final NoteEntity note;

  const UpdateNoteParams({required this.note});

  @override
  List<Object> get props => [note];
}

```

# presentation layer 

## bloc layer 
```dart
lib\features\notes\presentation\bloc\notes_events.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

/// Event to change the color of a note.
class ChangeNoteColorEvent extends NotesEvent {
  final NoteEntity note;
  final int newColor;

  const ChangeNoteColorEvent({required this.note, required this.newColor});

  @override
  List<Object> get props => [note, newColor];
}

/// Event to create a new note.
class CreateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const CreateNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}

/// Event to delete a note by its ID.
class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

class GetNoteByIdEvent extends NotesEvent {
  final String noteId;

  const GetNoteByIdEvent({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// Event to load all notes.
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Abstract base class for all Notes events.
/// All specific Notes events should extend this class.
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

/// Event to reorder notes.
class ReorderNotesEvent extends NotesEvent {
  final int oldIndex;
  final int newIndex;
  final List<NoteEntity> notes;
  const ReorderNotesEvent({required this.oldIndex, required this.newIndex, required this.notes});

  @override
  List<Object> get props => [oldIndex, newIndex, notes];
}

/// Event to search for notes based on a query.
class SearchNotesEvent extends NotesEvent {
  final String query;

  const SearchNotesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

/// Event to toggle the pinned status of a note.
class TogglePinNoteEvent extends NotesEvent {
  final NoteEntity note;

  const TogglePinNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}

/// Event to update an existing note.
class UpdateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const UpdateNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}

lib\features\notes\presentation\bloc\notes_states.dart
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart'; // Import Failure for error states
import '../../domain/entities/note_entity.dart';

/// State indicating a note has been successfully created.
class NoteCreatedSuccess extends NotesState {
  final NoteEntity note;

  const NoteCreatedSuccess({required this.note});

  @override
  List<Object> get props => [note];
}

/// State indicating a note has been successfully deleted.
class NoteDeletedSuccess extends NotesState {
  final String noteId;

  const NoteDeletedSuccess({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// State indicating an error occurred during a notes operation.
class NotesError extends NotesState {
  final Failure failure;

  const NotesError({required this.failure});

  @override
  List<Object> get props => [failure];
}

/// Initial state of the Notes BLoC.
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// State indicating that notes have been successfully loaded.
class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;

  const NotesLoaded({required this.notes});

  @override
  List<Object> get props => [notes];
}

/// State indicating that notes are currently being loaded or an operation is in progress.
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// State indicating notes have been successfully searched.
/// This can be combined with NotesLoaded if the UI doesn't need to distinguish.
/// For now, we'll keep it separate for clarity if specific search UI is needed.
class NotesSearchLoaded extends NotesState {
  final List<NoteEntity> searchResults;
  final String query;

  const NotesSearchLoaded({required this.searchResults, required this.query});

  @override
  List<Object> get props => [searchResults, query];
}

/// Abstract base class for all Notes states.
/// All specific Notes states should extend this class.
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

/// State indicating a note has been successfully updated.
class NoteUpdatedSuccess extends NotesState {
  final NoteEntity note;

  const NoteUpdatedSuccess({required this.note});

  @override
  List<Object> get props => [note];
}
class NoteLoadedById extends NotesState {
  final NoteEntity note;

  const NoteLoadedById({required this.note});

  @override
  List<Object> get props => [note];
}
lib\features\notes\presentation\bloc\notes_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs for new notes

import '../../../../core/usecases/usecase.dart'; // For NoParams
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_events.dart';
import 'notes_states.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final CreateNote createNoteUseCase;
  final GetNotes getNotesUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final SearchNotes searchNotesUseCase;
  final GetNoteById getNoteByIdUseCase; // NEW: Add GetNoteById use case

  NotesBloc({
    required this.createNoteUseCase,
    required this.getNotesUseCase,
    required this.getNoteByIdUseCase, // NEW: Add to constructor
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.searchNotesUseCase,
  }) : super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes);
    on<TogglePinNoteEvent>(_onTogglePinNote);
    on<ChangeNoteColorEvent>(_onChangeNoteColor);
    on<GetNoteByIdEvent>(_onGetNoteById); // NEW: Add handler for GetNoteByIdEvent
    on<ReorderNotesEvent>(_onReorderNotes); // NEW: Add handler for ReorderNotesEvent
  }
  Future<void> _onChangeNoteColor(ChangeNoteColorEvent event, Emitter<NotesState> emit) async {
    // Create a new NoteEntity with the updated color
    final updatedNote = event.note.copyWith(color: event.newColor);
    // Use the update use case
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // If successful, emit a success state and then reload notes to reflect changes
        emit(NoteUpdatedSuccess(note: note));
        add(const LoadNotes());
      },
    );
  }

  Future<void> _onCreateNote(CreateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteCreating
    // Ensure the note has a unique ID and creation timestamp if not already set
    final newNote = event.note.copyWith(
      id: event.note.id.isEmpty ? const Uuid().v4() : event.note.id,
      createdAt: event.note.createdAt,
    );

    final result = await createNoteUseCase(CreateNoteParams(note: newNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteCreatedSuccess(note: note)),
    );
    // After creation, you might want to reload all notes to update the list
    add(const LoadNotes());
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteDeleting
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (_) => emit(NoteDeletedSuccess(noteId: event.noteId)),
    );
    // After deletion, you might want to reload all notes to update the list
    add(const LoadNotes());
  }

  Future<void> _onGetNoteById(GetNoteByIdEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteLoadingById
    final result = await getNoteByIdUseCase(GetNoteByIdParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteLoadedById(note: note)),
    );
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await getNotesUseCase(NoParams());
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesLoaded(notes: notes)),
    );
  }

   Future<void> _onReorderNotes(ReorderNotesEvent event, Emitter<NotesState> emit) async {
    final notes = List<NoteEntity>.from(event.notes);

    // Separate pinned and unpinned notes
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    // Determine which list to reorder
    if (event.oldIndex < pinnedNotes.length && event.newIndex < pinnedNotes.length) {
      // Reordering within pinned notes
      final note = pinnedNotes.removeAt(event.oldIndex);
      pinnedNotes.insert(event.newIndex, note);
    } else if (event.oldIndex >= pinnedNotes.length && event.newIndex >= pinnedNotes.length) {
      // Reordering within unpinned notes
      final adjustedOldIndex = event.oldIndex - pinnedNotes.length;
      final adjustedNewIndex = event.newIndex - pinnedNotes.length;
      final note = unpinnedNotes.removeAt(adjustedOldIndex);
      unpinnedNotes.insert(adjustedNewIndex, note);
    }

    // Combine the lists back together
    final reorderedNotes = [...pinnedNotes, ...unpinnedNotes];

    // List to hold all update futures
    final List<Future<void>> updateFutures = [];

    // Update the order property of each note and save to database
    for (int i = 0; i < reorderedNotes.length; i++) {
      final noteToUpdate = reorderedNotes[i].copyWith(order: i);
      // Add the future to the list without awaiting immediately
      updateFutures.add(updateNoteUseCase(UpdateNoteParams(note: noteToUpdate)).then((result) {
        result.fold(
          (failure) {
            // يمكنك هنا التعامل مع الأخطاء الفردية لتحديث الملاحظات إذا لزم الأمر
            // على سبيل المثال، تسجيل الخطأ:
            print('Error updating note order for ${noteToUpdate.id}: ${failure.message}');
          },
          (_) {}, // النجاح، لا يلزم اتخاذ إجراء هنا
        );
      }));
    }

    // انتظر حتى تكتمل جميع تحديثات قاعدة البيانات
    await Future.wait(updateFutures);

    // بدلاً من إعادة تحميل جميع الملاحظات، قم بإصدار القائمة المعاد ترتيبها مباشرة.
    // هذا يضمن تحديث واجهة المستخدم بكفاءة دون جلب بيانات كامل.
    emit(NotesLoaded(notes: reorderedNotes));
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a specific state like NotesSearching
    final result = await searchNotesUseCase(SearchNotesParams(query: event.query));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesSearchLoaded(searchResults: notes, query: event.query)),
    );
  }

  Future<void> _onTogglePinNote(TogglePinNoteEvent event, Emitter<NotesState> emit) async {
    // Create a new NoteEntity with the toggled pinned status
    final updatedNote = event.note.copyWith(isPinned: !event.note.isPinned);
    // Use the update use case
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // If successful, emit a success state and then reload notes to reflect changes
        emit(NoteUpdatedSuccess(note: note));
        add(const LoadNotes());
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteUpdating
    final updatedNote = event.note.copyWith(updatedAt: DateTime.now());
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteUpdatedSuccess(note: note)),
    );
    // After update, you might want to reload all notes to update the list
    add(const LoadNotes());
  }
}

```

## pages layer 

```dart
lib\features\notes\presentation\pages\notes_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/routes/app_routes.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with RouteAware, TickerProviderStateMixin {
  final List<NoteEntity> _notes = [];
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: const ValueKey('search_button'),
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ),
      ],
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is NotesLoaded) {
            _updateNotesList(state.notes);
          }
        },
        builder: (context, state) {
          if (state is NotesLoading && _notes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotesLoaded || _notes.isNotEmpty) {
            if (_notes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // أيقونة كبيرة ومعبرة
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // عنوان رئيسي
                      Text(
                        'لا توجد ملاحظات بعد',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // رسالة توضيحية
                      Text(
                        'ابدأ رحلتك في تدوين الأفكار والملاحظات\nلتنظيم حياتك بشكل أفضل',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // زر إضافة ملاحظة جديدة
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/notes/add');
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'إضافة ملاحظة جديدة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 4.0,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // نصائح سريعة
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'نصيحة: يمكنك أيضاً استخدام الزر العائم في الأسفل لإضافة ملاحظات جديدة',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) => state is NotesLoaded
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                        itemCount: _notes.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<NotesBloc>().add(ReorderNotesEvent(
                                notes: state.notes,
                                oldIndex: oldIndex,
                                newIndex: newIndex > oldIndex ? newIndex - 1 : newIndex,
                              ));
                        },
                        itemBuilder: (context, index) {
                          if (index >= _notes.length) return const SizedBox.shrink();
                          return _buildNoteItem(_notes[index], index);
                        },
                        // Add proxyDecorator here to apply visual effects during drag
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              final double animValue = Curves.easeInOut.transform(animation.value);
                              final double scale = 1.0 + (0.05 * animValue); // Scale up by 5%
                              final double blurRadius =
                                  8.0 + (4.0 * animValue); // Blur from 8 to 12
                              final double spreadRadius =
                                  0.0 + (2.0 * animValue); // Spread from 0 to 2

                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                            0.1 + (0.05 * animValue)), // Slightly more opaque
                                        blurRadius: blurRadius,
                                        offset: const Offset(0, 4),
                                        spreadRadius: spreadRadius,
                                      ),
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05), // Keep this one constant
                                        blurRadius: 16.0,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: child, // The original NoteCard
                                ),
                              );
                            },
                            child: child,
                          );
                        },
                      )
                    : ListView());
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فشل تحميل الملاحظات',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.red[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.failure.message ?? "حدث خطأ غير معروف",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadNotes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('ابدأ بإضافة ملاحظاتك!'));
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            context.go('/notes/add');
          },
          icon: const Icon(Icons.add),
          label: const Text('ملاحظة جديدة'),
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadNotes(); // أعد تحميل الملاحظات عند العودة إلى هذه الصفحة
  }

  @override
  void didPush() {
    // يمكن استدعاؤه هنا إذا كنت تريد التأكد من التحميل عند الدفع الأول
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    _loadNotes(); // Initial load when the page is first created

    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  Widget _buildNoteItem(NoteEntity note, int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey(note.id),
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: NoteCard(
          note: note,
          onTap: () {
            context.go("/notes/view/${note.id}");
          },
          onTogglePin: () {
            context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
          },
          // Removed onLongPress from NoteCard as it's no longer needed there
        ),
      ),
    );
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(const LoadNotes());
  }

  // في _NotesPageState
  void _updateNotesList(List<NoteEntity> newNotes) {
    setState(() {
      _notes.clear();
      _notes.addAll(newNotes);
      // من الضروري أن يتطابق ترتيب الملاحظات في _notes مع الترتيب المستلم من حالة BLoC.
    });
  }
}

lib\features\notes\presentation\pages\note_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';

class NoteViewPage extends StatefulWidget {
  final String noteId; // Changed to receive noteId

  const NoteViewPage({super.key, required this.noteId});

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('عرض الملاحظة'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NoteLoadedById) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Use primary color
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0, // Added subtle elevation
                      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    onPressed: () {
                      // Navigate to AddNotesPage for editing, passing the note as extra
                      context.go('/notes/add', extra: state.note);
                    },
                  ),
                );
              }
              return const SizedBox.shrink(); // Hide edit button if note not loaded
            },
          ),
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NoteLoadedById) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0, // Added subtle elevation
                      shadowColor: Colors.red.withOpacity(0.3),
                    ),
                    onPressed: () {
                      _confirmDelete(context, state.note.id);
                    },
                  ),
                );
              }
              return const SizedBox.shrink(); // Hide delete button if note not loaded
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('تم حذف الملاحظة بنجاح!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NoteLoadedById) {
            final note = state.note;

            // Determine the background color for the note card
            final Color baseCardColor = Theme.of(context).cardColor;
            final Color noteDisplayColor =
                note.color != null ? Color(note.color!) : Colors.transparent;

            // Blend the note's color with the base card color for a subtle tint
            final Color blendedNoteBgColor = Color.alphaBlend(
              noteDisplayColor.withOpacity(0.2), // 20% of the note's color
              baseCardColor,
            );

            // Determine title text color based on note's color luminance for readability
            Color titleTextColor;
            if (note.color != null) {
              final Color actualNoteColor = Color(note.color!);
              if (ThemeData.estimateBrightnessForColor(actualNoteColor) == Brightness.light) {
                titleTextColor = Colors.black87; // Use dark text for light colors
              } else {
                titleTextColor = Colors.white; // Use light text for dark colors
              }
            } else {
              titleTextColor = Theme.of(context).textTheme.headlineMedium?.color ??
                  Colors.black; // Default theme text color
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: blendedNoteBgColor, // Use the blended background color
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08), // Softer shadow
                        blurRadius: 15.0, // Reduced blur
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note title with enhanced styling
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            note.title.isNotEmpty ? note.title : 'ملاحظة بدون عنوان',
                            key: ValueKey(note.title),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleTextColor, // Use adaptive title text color
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date information with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.5), // Use theme surface variant
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color, // Use theme text color
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'تم الإنشاء: ${DateFormat('yyyy-MM-dd HH:mm').format(note.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              if (note.updatedAt != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color, // Use theme text color
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm').format(note.updatedAt!)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Note content with enhanced styling
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor, // Use theme card color
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.5), // Subtle border
                                width: 1,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  note.content.isNotEmpty ? note.content : 'لا يوجد محتوى',
                                  key: ValueKey(note.content),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        height: 1.6,
                                        color: note.content.isNotEmpty
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color // Use theme text color
                                            : Colors.grey[500],
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فشل تحميل الملاحظة',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.red[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.failure.message ?? "حدث خطأ غير معروف",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<NotesBloc>().add(GetNoteByIdEvent(noteId: widget.noteId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('جاري تحميل الملاحظة...'));
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Dispatch event to load the specific note
    context.read<NotesBloc>().add(GetNoteByIdEvent(noteId: widget.noteId));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeAnimationController.forward();
      _slideAnimationController.forward();
    });
  }

  void _confirmDelete(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange[600],
              ),
              const SizedBox(width: 8),
              const Text('تأكيد الحذف'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذه الملاحظة؟ لا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(height: 1.4),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('حذف'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                context.read<NotesBloc>().add(DeleteNoteEvent(noteId: noteId));
              },
            ),
          ],
        );
      },
    );
  }
}

lib\features\notes\presentation\pages\add_notes_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:zenlearn/core/widgets/custom_input.dart'; // Make sure this path is correct
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/color_picker_widget.dart';

class AddNotesPage extends StatefulWidget {
  final NoteEntity? existingNote; // Optional: for editing existing notes

  const AddNotesPage({super.key, this.existingNote});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedColor; // To store the selected color

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.existingNote == null ? 'إضافة ملاحظة جديدة' : 'تعديل ملاحظة'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                elevation: 4.0, // Added subtle elevation
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteCreatedSuccess || state is NoteUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(widget.existingNote == null
                        ? 'تم حفظ الملاحظة بنجاح!'
                        : 'تم تحديث الملاحظة بنجاح!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('خطأ في الحفظ: ${state.failure.message ?? "حدث خطأ غير معروف"}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Title input with enhanced styling
                  CustomInput(
                    controller: _titleController,
                    hintText: 'عنوان الملاحظة',
                    maxLines: null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    borderRadius: 16.0,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16), // Adjusted padding
                  ),
                  const SizedBox(height: 20),

                  // Content input with enhanced styling
                  Expanded(
                    child: CustomInput(
                      controller: _contentController,
                      hintText: 'اكتب ملاحظتك هنا...',
                      maxLines: null,
                      minLines: 1,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      borderRadius: 16.0,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16), // Adjusted padding
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color picker with enhanced styling
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Material(
                      // Wrap with Material for elevation
                      key: ValueKey(_selectedColor),
                      elevation: 4.0, // Added elevation
                      shadowColor: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.palette,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'لون الملاحظة',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ColorPickerWidget(
                              selectedColor: _selectedColor,
                              onColorSelected: (color) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
    }

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideAnimationController.forward();
      _fadeAnimationController.forward();
    });
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('لا يمكن حفظ ملاحظة فارغة.'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (widget.existingNote == null) {
      // Create new note
      final newNote = NoteEntity(
        id: const Uuid().v4(), // Generate a unique ID for the new note
        title: title,
        content: content,
        createdAt: DateTime.now(),
        isPinned: false,
        color: _selectedColor,
      );
      context.read<NotesBloc>().add(CreateNoteEvent(note: newNote));
    } else {
      // Update existing note
      final updatedNote = widget.existingNote!.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        color: _selectedColor,
      );
      context.read<NotesBloc>().add(UpdateNoteEvent(note: updatedNote));
    }
  }
}

```

## widgets layer
```dart 
lib\features\notes\presentation\widgets\color_picker_widget.dart
import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  final int? selectedColor;
  final ValueChanged<int?> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.transparent, // Option for no color
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: colors.map((color) {
        final int colorValue = color.value;
        final bool isSelected = selectedColor == colorValue;
        return GestureDetector(
          onTap: () {
            // If transparent is selected and it's already the selected color, deselect it (set to null)
            if (color == Colors.transparent && isSelected) {
              onColorSelected(null);
            } else {
              onColorSelected(colorValue);
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: color == Colors.transparent
                ? Center(
                    child: Icon(
                      Icons.close,
                      color: isSelected ? Colors.black : Colors.grey,
                      size: 20,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
lib\features\notes\presentation\widgets\note_card.dart
import 'package:flutter/material.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  // Changed to StatelessWidget
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  // Removed all animation and long press state/methods (_animationController, _scaleAnimation, _isLongPressed, initState, dispose, _handleLongPressStart, _handleLongPressEnd, _handleTapCancel)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Only handle tap
      // Removed onLongPressStart, onLongPressEnd, onTapCancel, onLongPressCancel
      child: Container(
        // Removed AnimatedBuilder and Transform.scale
        // margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            // Simplified boxShadow - no longer depends on _isLongPressed
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0, // Fixed blurRadius
              offset: const Offset(0, 4),
              spreadRadius: 0, // Fixed spreadRadius
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: note.color != null ? Color(note.color!) : Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isNotEmpty ? note.title : 'ملاحظة بدون عنوان',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Always show drag handle icon
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(note.isPinned),
                        icon: Icon(
                          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: note.isPinned ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        onPressed: onTogglePin,
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      _formatDate(note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}

```