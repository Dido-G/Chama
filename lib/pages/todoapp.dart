import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatefulWidget {
  static List<Map<String, dynamic>> tasks = [];

  const TodoApp({super.key}); 

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  void addTask(String task, double weight) {
    if (task.isNotEmpty) {
      setState(() {
        TodoApp.tasks.add({"title": task, "isDone": false, "weight": weight});
      });
    }
  }

  void addSmartGadget(String gadgetName, double weight) {
    if (gadgetName.isNotEmpty) {
      setState(() {
        TodoApp.tasks.add({
          "title": gadgetName, 
          "isDone": false,
          "weight": weight, 
          "isGadget": true, 
        });
      });
    }
  }

  void toggleTask(int index) {
    setState(() {
      TodoApp.tasks[index]["isDone"] = !(TodoApp.tasks[index]["isDone"] ?? false);
    });
  }

  void deleteTask(int index) {
    setState(() {
      TodoApp.tasks.removeAt(index); 
    });
  }

  void showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    double taskWeight = 1.0; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Add Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(hintText: "Enter task..."),
                  ),
                  SizedBox(height: 10),
                  Text("Task Weight: ${taskWeight.toStringAsFixed(1)}"),
                  Slider(
                    value: taskWeight,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    label: taskWeight.toStringAsFixed(1),
                    onChanged: (value) {
                      setDialogState(() {
                        taskWeight = value; 
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    addTask(taskController.text, taskWeight);
                    Navigator.pop(context);
                  },
                  child: Text("Add Task"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddSmartGadgetDialog() {
    TextEditingController gadgetController = TextEditingController();
    double gadgetWeight = 1.0; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Add Smart Gadget"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gadgetController,
                    decoration: InputDecoration(hintText: "Enter gadget name..."),
                  ),
                  SizedBox(height: 10),
                  Text("Gadget Weight: ${gadgetWeight.toStringAsFixed(1)}"),
                  Slider(
                    value: gadgetWeight,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    label: gadgetWeight.toStringAsFixed(1),
                    onChanged: (value) {
                      setDialogState(() {
                        gadgetWeight = value; 
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    addSmartGadget(gadgetController.text, gadgetWeight);
                    Navigator.pop(context);
                  },
                  child: Text("Add Gadget"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List with Gadgets"),
        centerTitle: true,
        backgroundColor: Color(0xFFE8C6B6),
      ),
      backgroundColor: Color(0xFFF5E6E0),
      body: TodoApp.tasks.isEmpty
          ? Center(child: Text("No tasks yet. Add one!", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: TodoApp.tasks.length,
              itemBuilder: (context, index) {
                String title = TodoApp.tasks[index]["title"] ?? "Unknown";
                String subtitle = "";

                if (TodoApp.tasks[index].containsKey("weight")) {
                  subtitle = "Weight: ${TodoApp.tasks[index]["weight"]}";
                }

                bool isGadget = TodoApp.tasks[index]["isGadget"] ?? false;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  color: isGadget ? Colors.lightBlueAccent : null, 
                  child: ListTile(
                    leading: Checkbox(
                      value: TodoApp.tasks[index]["isDone"] ?? false, 
                      onChanged: (value) => toggleTask(index),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isGadget ? FontWeight.bold : FontWeight.normal, 
                        decoration: (TodoApp.tasks[index]["isDone"] ?? false)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(subtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        if (isGadget)
                          Icon(Icons.devices, color: Colors.blue), 
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red), 
                          onPressed: () => deleteTask(index), 
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: showAddTaskDialog,
            backgroundColor: Colors.deepPurple[300],
            child: Icon(Icons.add, size: 30),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: showAddSmartGadgetDialog,
            backgroundColor: const Color.fromARGB(255, 98, 149, 237),
            child: Icon(Icons.devices, size: 30),
          ),
        ],
      ),
    );
  }
}