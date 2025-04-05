class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? startTime;
  final DateTime? endTime;
  final String userId;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      userId: map['userId'],
    );
  }
}
