import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class AddSubTodo implements UseCase<void, SubtodoEntity> {

  AddSubTodo(this.repository);
  final TodoRepository repository;

  @override
  Future<void> call(SubtodoEntity subTodo) {
    return repository.addSubTodo(subTodo);
  }
}