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
