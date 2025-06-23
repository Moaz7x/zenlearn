import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';


class GetTodoById implements UseCase<TodoEntity?, int> {
  final TodoRepository repository;

  GetTodoById(this.repository);

  @override
  Future<TodoEntity?> call(int id) {
    return repository.getTodoById(id);
  }
}