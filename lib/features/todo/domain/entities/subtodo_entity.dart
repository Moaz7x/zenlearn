class SubtodoEntity {
  final int? id;
  final String title;
  late final bool isCompleted;
  final int todoId;

  SubtodoEntity({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.todoId,
  });

  SubtodoEntity copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? todoId,
  }) {
    return SubtodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      todoId: todoId ?? this.todoId,
    );
  }
}
