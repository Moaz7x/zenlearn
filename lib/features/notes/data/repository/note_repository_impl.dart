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
