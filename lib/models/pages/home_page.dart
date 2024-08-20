import 'package:flutter/material.dart';
import 'package:task_management_app/models/task_model.dart';
import 'package:task_management_app/services/task_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _taskEditingController.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            controller: _taskEditingController,
            decoration: const InputDecoration(
              hintText: "Enter Task Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            //cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            //save button
            TextButton(
              onPressed: () async {
                await TaskService().addTask(_taskEditingController.text);
                _taskEditingController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  //open a bottom sheet
  void _showEditTaskBottomSheet(Task task) {
    _taskEditingController.text = task.name;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  TextField(
                    controller: _taskEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Task Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      task.name = _taskEditingController.text;
                      task.updatedAt = DateTime.now();
                      task.isUpdated = true;

                      await TaskService().updateTask(task);
                      _taskEditingController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Update Task'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task App"),
      ),
      body: StreamBuilder(
        stream: TaskService().getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading tasks"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No task availabe"),
            );
          } else {
            final List<Task> tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final Task task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      task.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created: ${task.createdAt}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          'Updated: ${task.updatedAt}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        TaskService().deleteTask(task.id);
                      },
                      icon: Icon(Icons.delete),
                    ),
                    onTap: () {
                      _showEditTaskBottomSheet(task);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
