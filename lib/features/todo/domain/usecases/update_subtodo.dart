import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class UpdateSubTodo implements UseCase<void, SubtodoEntity> {
  final TodoRepository repository;
  UpdateSubTodo(this.repository);

  @override
  Future<void> call(SubtodoEntity todo) {
    return repository.updateSubTodo(todo);
  }
}
