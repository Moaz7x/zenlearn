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
