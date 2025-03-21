import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class GenerativeModel {
  final String model;
  final String apiKey;

  GenerativeModel({required this.model, required this.apiKey});

  Future<GeneratedContent> generateContent(List<Content> content) async {
    await Future.delayed(Duration(seconds: 2)); 
    return GeneratedContent(text: "The person is of normal weight and should focus on both physical and mental health. Here is a recommended program.");
  }
}

class GeneratedContent {
  final String text;
  GeneratedContent({required this.text});
}

class Content {
  final String text;

  Content.text(this.text);
}

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  String savedWeight = '';
  String savedHeight = '';
  String savedAge = '';
  String savedJob = '';
  String savedHours = '';
  String savedDays = '';
  String aiResponse = ''; 

  String apiKey = ''; 

  @override
  void initState() {
    super.initState();
    loadApiKey(); 
  }

 
  Future<void> loadApiKey() async {
    String key = await rootBundle.loadString('apiKey/key.txt');
    setState(() {
      apiKey = key.trim(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Information"),
        centerTitle: true,
        backgroundColor: Color(0xFFE8C6B6),
      ),
      backgroundColor: Color(0xFFF5E6E0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your personal information:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _jobController,
                    decoration: InputDecoration(
                      labelText: 'Job ',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your job ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                 
                  TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Hours per day',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hours worked per day';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Days per week',
                      border: OutlineInputBorder(),
                      filled: true, 
                      fillColor: Colors.white, 
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter days worked per week';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());

                      if (_formKey.currentState?.validate() ?? false) {
                        String weight = _weightController.text;
                        String height = _heightController.text;
                        String age = _ageController.text;
                        String job = _jobController.text;
                        String hours = _hoursController.text;
                        String days = _daysController.text;

                        setState(() {
                          savedWeight = weight;
                          savedHeight = height;
                          savedAge = age;
                          savedJob = job;
                          savedHours = hours;
                          savedDays = days;
                        });

                        _weightController.clear();
                        _heightController.clear();
                        _ageController.clear();
                        _jobController.clear();
                        _hoursController.clear();
                        _daysController.clear();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Profile Saved"),
                              content: Text(
                                  "Weight: $weight kg\nHeight: $height cm\nAge: $age years\nJob: $job\nHours/Day: $hours\nDays/Week: $days"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text("Save Information"),
                  ),
                  const SizedBox(height: 20),

                  if (savedWeight.isNotEmpty &&
                      savedHeight.isNotEmpty &&
                      savedAge.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Saved Information:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text("Weight: $savedWeight kg"),
                        Text("Height: $savedHeight cm"),
                        Text("Age: $savedAge years"),
                        Text("Job: $savedJob"),
                        Text("Hours/Day: $savedHours"),
                        Text("Days/Week: $savedDays"),
                      ],
                    ),

                  ElevatedButton(
                    onPressed: generateAIContent, 
                    child: const Text("Generate AI Health & Program"),
                  ),
                  const SizedBox(height: 20),

                  if (aiResponse.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AI Response:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(aiResponse),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateAIContent() async {
    final weight = double.tryParse(savedWeight);
    final height = double.tryParse(savedHeight);

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      setState(() {
        aiResponse = "Invalid input. Please enter valid weight and height.";
      });
      return;
    }

    double bmi = weight / ((height / 100) * (height / 100));

    String classification;
    if (bmi < 18.5) {
      classification = "Skinny";
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      classification = "Normal";
    } else {
      classification = "Overweight";
    }

    String program = generateWeeklyProgram();

    // Set AI response
    setState(() {
      aiResponse = "Based on your BMI ($bmi), you are $classification.\n\nWeekly Program:\n$program";
    });
  }

  String generateWeeklyProgram() {
    String program = "";

    if (savedAge.isNotEmpty) {
      int age = int.parse(savedAge);
      program += "Physical Training:\n";

      if (age < 30) {
        program += "- Daily cardio (e.g., running, cycling)\n";
        program += "- Strength training 3 times a week\n";
      } else if (age < 50) {
        program += "- Cardio 3 times a week\n";
        program += "- Flexibility and strength training 2 times a week\n";
      } else {
        program += "- Light cardio (e.g., walking) every other day\n";
        program += "- Flexibility exercises (e.g., yoga)\n";
      }

      program += "\nMental Health Program:\n";

      if (savedJob.toLowerCase().contains("stress") || int.parse(savedHours) > 8) {
        program += "- Practice mindfulness meditation daily\n";
        program += "- Take short breaks throughout the day\n";
      } else {
        program += "- Enjoy relaxing activities like reading\n";
        program += "- Spend quality time with friends/family\n";
      }
    }

    return program;
  }
}