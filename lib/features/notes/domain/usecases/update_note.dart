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
