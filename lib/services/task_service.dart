import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> addSubtask(String parentTaskId, Task subtask) async {
    final parentTaskRef = _firestore.collection('tasks').doc(parentTaskId);
    final parentTask = await parentTaskRef.get();
    final currentSubtasks = parentTask.data()?['subtasks'] ?? [];
    
    await parentTaskRef.update({
      'subtasks': [...currentSubtasks, subtask.toMap()],
    });
  }
}
