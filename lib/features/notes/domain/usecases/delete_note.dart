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
