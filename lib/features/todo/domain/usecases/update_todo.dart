import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';
import '../../../../core/usecases/usecase.dart';

class UpdateTodo implements UseCase<void, TodoEntity> {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  @override
  Future<void> call(TodoEntity todo) {
    return repository.updateTodo(todo);
  }
}
