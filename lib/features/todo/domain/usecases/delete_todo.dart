import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class DeleteTodo implements UseCase<void, int> {
  final TodoRepository repository;
  DeleteTodo(this.repository);

  @override
  Future<void> call(int id) {
    return repository.deleteTodo(id);
  }
}
