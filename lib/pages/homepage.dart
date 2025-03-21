import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/todoapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int streak = 0;
  Timer? _timer;

 @override
void initState() {
  super.initState();
  _resetStreakOnStart(); // Force streak to start from 0
  _loadStreak(); // Load streak from local storage
  _startTimeCheck(); // Start checking the time every minute
}

// Reset streak to 0 on app start
Future<void> _resetStreakOnStart() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('streak', 0); // Force reset streak to 0 on app start
}


  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when disposed
    super.dispose();
  }

  // Load streak count from local storage
  Future<void> _loadStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('streak') ?? 0; // Default to 0 if no streak is found
    });
  }

  // Save streak count to local storage
  Future<void> _saveStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
  }

  // Check time every minute and reset tasks at 22:00 if all are done
  void _startTimeCheck() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 22 && now.minute == 00) {
        _resetTasksIfComplete();
      }
    });
  }

  // Reset tasks if all tasks are completed and increase streak
  void _resetTasksIfComplete() {
    if (!mounted) return;

    bool allTasksCompleted = TodoApp.tasks.every((task) => task["isDone"]);

    if (allTasksCompleted) {
      setState(() {
        streak++; // Increase streak by 1
        _saveStreak(); // Save streak to local storage
        TodoApp.tasks.forEach((task) {
          task["isDone"] = false; // Reset all tasks to not done
        });
      });
    }
  }

  // Calculate task progress based on completed tasks
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
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: Text("🔥 Streak: $streak", style: const TextStyle(fontSize: 18))),
          ),
        ],
      ),
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
                          elevation: isGadget ? 5 : 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: isGadget ? Colors.lightBlueAccent : null,
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
                                fontWeight: isGadget ? FontWeight.bold : FontWeight.normal,
                                decoration: TodoApp.tasks[index]["isDone"]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              isGadget
                                  ? "Gadget Weight: ${TodoApp.tasks[index]["weight"]}"
                                  : "Weight: ${TodoApp.tasks[index]["weight"]}",
                            ),
                            trailing: isGadget
                                ? const Icon(Icons.devices, color: Colors.blue)
                                : null,
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
