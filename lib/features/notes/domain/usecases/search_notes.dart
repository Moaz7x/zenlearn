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
