import '../repositories/todo_repository.dart';
import '../../../../core/usecases/usecase.dart';

class ToggleTodoCompletionUseCase implements UseCase<void, int> {
  final TodoRepository repository;

  ToggleTodoCompletionUseCase(this.repository);

  @override
  Future<void> call(int id) {
    return repository.toggleTodoCompletion(id);
  }
}