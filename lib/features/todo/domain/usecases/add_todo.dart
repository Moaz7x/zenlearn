import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class AddTodo implements UseCase<void, TodoEntity> {

  AddTodo(this.repository);
  final TodoRepository repository;

  @override
  Future<void> call(TodoEntity todo) {
    return repository.addTodo(todo);
  }
}