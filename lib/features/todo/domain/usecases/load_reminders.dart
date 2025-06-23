import 'package:zenlearn/core/usecases/usecase.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/domain/repositories/todo_repository.dart';

class LoadRemindersUseCase extends UseCase<List<ReminderEntity>, int> {
  final TodoRepository repository;
  LoadRemindersUseCase(this.repository);
  @override
  Future<List<ReminderEntity>> call(int params) async {
    return await repository.getAllReminders(params);
  }
}
