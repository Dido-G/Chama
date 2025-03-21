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

  final Color mainColor = const Color(0xFFE8C6B6);
  final Color backgroundColor = const Color(0xFFF5E6E0); 

  @override
  void initState() {
    super.initState();
    _resetStreakOnStart(); 
    _loadStreak(); 
    _startTimeCheck(); 
  }

  Future<void> _resetStreakOnStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', 0); 
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _loadStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('streak') ?? 0; 
    });
  }

  Future<void> _saveStreak() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
  }

  void _startTimeCheck() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 22 && now.minute == 00) {
        _resetTasksIfComplete();
      }
    });
  }

  void _resetTasksIfComplete() {
    if (!mounted) return;

    bool allTasksCompleted = TodoApp.tasks.every((task) => task["isDone"]);

    if (allTasksCompleted) {
      setState(() {
        streak++; 
        _saveStreak(); 
        TodoApp.tasks.forEach((task) {
          task["isDone"] = false; 
        });
      });
    }
  }

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
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: mainColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                "🔥 Streak: $streak",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Task Progress",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Progress bar inside a box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(10), 
                border: Border.all(color: mainColor, width: 2), 
              ),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: mainColor,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toStringAsFixed(1)}%", 
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TodoApp.tasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No tasks available.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: TodoApp.tasks.length,
                      itemBuilder: (context, index) {
                        bool isGadget = TodoApp.tasks[index]["isGadget"] ?? false;

                        return Card(
                          elevation: isGadget ? 5 : 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: isGadget ? Colors.lightBlueAccent : Colors.white, 
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