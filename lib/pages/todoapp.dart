// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatefulWidget {
  static List<Map<String, dynamic>> tasks = [];

  const TodoApp({super.key}); // Static list to share across pages

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  // Function to add tasks with title and weight
  void addTask(String task, double weight) {
    if (task.isNotEmpty) {
      setState(() {
        TodoApp.tasks.add({"title": task, "isDone": false, "weight": weight});
      });
    }
  }

  // Function to add smart gadgets with name, weight
  void addSmartGadget(String gadgetName, double weight) {
    if (gadgetName.isNotEmpty) {
      setState(() {
        TodoApp.tasks.add({
          "title": gadgetName, // Use "title" for gadget
          "isDone": false,
          "weight": weight, // Weight for gadget as well
          "isGadget": true, // Adding a new flag to identify gadgets
        });
      });
    }
  }

  // Function to toggle the "isDone" state of tasks
  void toggleTask(int index) {
    setState(() {
      TodoApp.tasks[index]["isDone"] = !(TodoApp.tasks[index]["isDone"] ?? false);
    });
  }

  // Function to show the "Add Task" dialog
  void showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    double taskWeight = 1.0; // Default weight

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
                        taskWeight = value; // Updates UI inside dialog
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

  // Function to show the "Add Smart Gadget" dialog
  void showAddSmartGadgetDialog() {
    TextEditingController gadgetController = TextEditingController();
    double gadgetWeight = 1.0; // Default weight for gadget

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
                        gadgetWeight = value; // Updates UI inside dialog
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
        backgroundColor: Colors.deepPurple,
      ),
      body: TodoApp.tasks.isEmpty
          ? Center(child: Text("No tasks yet. Add one!", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: TodoApp.tasks.length,
              itemBuilder: (context, index) {
                // Safe Access to the "title" field (either task or gadget)
                String title = TodoApp.tasks[index]["title"] ?? "Unknown";
                String subtitle = "";

                // Display weight for tasks and gadgets
                if (TodoApp.tasks[index].containsKey("weight")) {
                  subtitle = "Weight: ${TodoApp.tasks[index]["weight"]}";
                }

                bool isGadget = TodoApp.tasks[index]["isGadget"] ?? false;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  color: isGadget ? Colors.lightBlueAccent : null, // Different color for gadgets
                  child: ListTile(
                    leading: Checkbox(
                      value: TodoApp.tasks[index]["isDone"] ?? false, // Default to false if isDone is null
                      onChanged: (value) => toggleTask(index),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isGadget ? FontWeight.bold : FontWeight.normal, // Bold for gadgets
                        decoration: (TodoApp.tasks[index]["isDone"] ?? false)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(subtitle),
                    trailing: isGadget
                        ? Icon(Icons.devices, color: Colors.blue) // Gadget-specific icon
                        : null, // No icon for regular tasks
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: showAddTaskDialog,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.add, size: 30),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: showAddSmartGadgetDialog,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.devices, size: 30),
          ),
        ],
      ),
    );
  }
}
