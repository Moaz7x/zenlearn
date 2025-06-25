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
