import 'package:zenlearn/core/usecases/usecase.dart';
import 'package:zenlearn/features/todo/domain/repositories/todo_repository.dart';

class DeleteReminder implements UseCase<void, int> {
  final TodoRepository repository;
  DeleteReminder(this.repository);

  @override
  Future<void> call(int id) {
    return repository.deleteReminder(id);
  }
}
