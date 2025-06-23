import 'package:zenlearn/core/usecases/usecase.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
import 'package:zenlearn/features/todo/domain/repositories/todo_repository.dart';

class FilterTodosUsecaseAll extends UseCase<List<TodoEntity>, int> {
  final TodoRepository repository;
  FilterTodosUsecaseAll(this.repository);

  @override
  Future<List<TodoEntity>> call(int params) {
    return repository.filterTodosByPriorityAll(params);
  }
}
class FilterTodosUsecaseCompleated extends UseCase<List<TodoEntity>, int> {
  final TodoRepository repository;
  FilterTodosUsecaseCompleated(this.repository);

  @override
  Future<List<TodoEntity>> call(int params) {
    return repository.filterTodosByPriorityCompleted(params);
  }
}
class FilterTodosUsecaseDueDated extends UseCase<List<TodoEntity>, int> {
  final TodoRepository repository;
  FilterTodosUsecaseDueDated(this.repository);

  @override
  Future<List<TodoEntity>> call(int params) {
    return repository.filterTodosByPriorityDueDated(params);
  }
}
