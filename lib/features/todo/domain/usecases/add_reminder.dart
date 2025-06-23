import 'package:zenlearn/core/usecases/usecase.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/domain/repositories/todo_repository.dart';

class AddReminder implements UseCase<void, ReminderEntity> {
  final TodoRepository repository;
  AddReminder(this.repository);

  @override
  Future<void> call(ReminderEntity reminder) {
    return repository.addReminder(reminder);
  }
}
