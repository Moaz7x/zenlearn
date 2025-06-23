import '../../../../core/usecases/usecase.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetAllTodos implements UseCase<List<TodoEntity>, NoParams> {
  final TodoRepository repository;

  GetAllTodos(this.repository);

  @override
  Future<List<TodoEntity>> call(NoParams params) {
    return repository.getAllTodos();
  }
}