import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class ToggleSubTodoCompletionUseCase implements UseCase<void, int> {
  final TodoRepository repository;
  ToggleSubTodoCompletionUseCase(this.repository);

  @override
  Future<void> call(int id) {
    return repository.toggleSubTodoCompletion(id);
  }
}
