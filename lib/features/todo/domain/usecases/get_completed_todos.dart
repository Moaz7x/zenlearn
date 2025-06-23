import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetAllCompletedTodos implements UseCase<List<TodoEntity>, NoParams> {
  final TodoRepository repository;

  GetAllCompletedTodos(this.repository);

  @override
  Future<List<TodoEntity>> call(NoParams params) {
    return repository.getAllCompletedTodos();
  }
}