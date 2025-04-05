import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  String? _selectedParentTaskId;

  @override
  void dispose() {
    _taskController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        if (isStartTime) {
          _selectedStartTime = selectedDateTime;
        } else {
          _selectedEndTime = selectedDateTime;
        }
      });
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _taskController.text,
        startTime: _selectedStartTime,
        endTime: _selectedEndTime,
        userId: context.read<AuthService>().currentUser!.uid,
      );
      context.read<TaskService>().addTask(task);
      _taskController.clear();
      setState(() {
        _selectedStartTime = null;
        _selectedEndTime = null;
      });
    }
  }

  void _addSubtask(String parentTaskId) {
    if (_subtaskController.text.isNotEmpty) {
      final subtask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _subtaskController.text,
        userId: context.read<AuthService>().currentUser!.uid,
      );
      context.read<TaskService>().addSubtask(parentTaskId, subtask);
      _subtaskController.clear();
      setState(() {
        _selectedParentTaskId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedStartTime == null || _selectedEndTime == null
                      ? null
                      : _addTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text(_selectedStartTime == null
                      ? 'Select Start Time'
                      : DateFormat.jm().format(_selectedStartTime!)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text(_selectedEndTime == null
                      ? 'Select End Time'
                      : DateFormat.jm().format(_selectedEndTime!)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: context.read<TaskService>().getTasks(
                    context.read<AuthService>().currentUser!.uid,
                  ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                context
                                    .read<TaskService>()
                                    .updateTaskCompletion(task.id, value!);
                              },
                            ),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context.read<TaskService>().deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                        subtitle: task.startTime != null && task.endTime != null
                            ? Text(
                                '${DateFormat.jm().format(task.startTime!)} - ${DateFormat.jm().format(task.endTime!)}')
                            : null,
                        children: [
                          if (task.subtasks != null)
                            ...task.subtasks!.map((subtask) => ListTile(
                                  title: Text(subtask.title),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      // Implement subtask deletion
                                    },
                                  ),
                                )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _subtaskController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter subtask',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _addSubtask(task.id),
                                  child: const Text('Add Subtask'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
