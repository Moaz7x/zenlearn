import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class DeleteSubTodo implements UseCase<void, int> {
  final TodoRepository repository;
  DeleteSubTodo(this.repository);

  @override
  Future<void> call(int id) {
    return repository.deleteSubTodo(id);
  }
}
