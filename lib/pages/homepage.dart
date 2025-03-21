import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/todoapp.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  double calculateProgress() {
    if (TodoApp.tasks.isEmpty) return 0.0;

    double totalWeight = TodoApp.tasks.fold(0, (sum, task) => sum + task["weight"]);
    double completedWeight = TodoApp.tasks
        .where((task) => task["isDone"])
        .fold(0, (sum, task) => sum + task["weight"]);

    return completedWeight / totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    double progress = calculateProgress();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true, backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Task Progress", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.deepPurple,
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TodoApp.tasks.isEmpty
                  ? const Center(child: Text("No tasks available.", style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: TodoApp.tasks.length,
                      itemBuilder: (context, index) {
                        bool isGadget = TodoApp.tasks[index]["isGadget"] ?? false;

                        return Card(
                          elevation: isGadget ? 5 : 2, // Higher elevation for gadgets
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: isGadget ? Colors.lightBlueAccent : null, // Different color for gadgets
                          child: ListTile(
                            leading: Checkbox(
                              value: TodoApp.tasks[index]["isDone"],
                              onChanged: (value) {
                                setState(() {
                                  TodoApp.tasks[index]["isDone"] = value!;
                                });
                              },
                            ),
                            title: Text(
                              TodoApp.tasks[index]["title"] ?? "Unknown",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isGadget ? FontWeight.bold : FontWeight.normal, // Bold for gadgets
                                decoration: TodoApp.tasks[index]["isDone"]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              isGadget
                                  ? "Gadget Weight: ${TodoApp.tasks[index]["weight"]}" // For gadgets
                                  : "Weight: ${TodoApp.tasks[index]["weight"]}", // For tasks
                            ),
                            trailing: isGadget
                                ? const Icon(Icons.devices, color: Colors.blue) // Gadget icon
                                : null, // No icon for regular tasks
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
