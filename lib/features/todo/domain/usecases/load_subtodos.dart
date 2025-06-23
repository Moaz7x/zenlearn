import 'package:zenlearn/core/usecases/usecase.dart';
import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';
import 'package:zenlearn/features/todo/domain/repositories/todo_repository.dart';

class LoadSubtodos implements UseCase<List<SubtodoEntity>, int> {
  final TodoRepository repository;
  LoadSubtodos(this.repository);
  @override
  Future<List<SubtodoEntity>> call(int todoId) {
    return repository.getAllSubTodos(todoId);
  }
}
