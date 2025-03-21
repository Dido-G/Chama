import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading the asset file

// Dummy classes for the AI model and content generation (replace with actual implementation)
class GenerativeModel {
  final String model;
  final String apiKey;

  GenerativeModel({required this.model, required this.apiKey});

  Future<GeneratedContent> generateContent(List<Content> content) async {
    // Simulate an AI call, replace this with actual AI model logic
    await Future.delayed(Duration(seconds: 2)); // Simulating API call delay
    return GeneratedContent(text: "The person is of normal weight.");
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
  // Controllers for input fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  // Variables to hold the saved information
  String savedWeight = '';
  String savedHeight = '';
  String savedAge = '';
  String savedJob = '';
  String savedHours = '';
  String savedDays = '';
  String aiResponse = ''; // To hold the AI's response

  String apiKey = ''; // To hold the API key from the file

  @override
  void initState() {
    super.initState();
    loadApiKey(); // Load the API key when the page initializes
  }

  // Function to load the API key from the assets file
  Future<void> loadApiKey() async {
    String key = await rootBundle.loadString('apiKey/key.txt');
    setState(() {
      apiKey = key.trim(); // Remove any extra spaces or newline characters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Information"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
      ),
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

                  // Weight field
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Height field
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Age field
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Job field
                  TextFormField(
                    controller: _jobController,
                    decoration: const InputDecoration(
                      labelText: 'Job Type',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your job type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Hours per day field
                  TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours per day',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hours worked per day';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Days per week field
                  TextFormField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Days per week',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter days worked per week';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      // Dismiss keyboard
                      FocusScope.of(context).requestFocus(FocusNode());

                      // Validate the form and save if valid
                      if (_formKey.currentState?.validate() ?? false) {
                        // Get the entered data
                        String weight = _weightController.text;
                        String height = _heightController.text;
                        String age = _ageController.text;
                        String job = _jobController.text;
                        String hours = _hoursController.text;
                        String days = _daysController.text;

                        // Save the data and update UI
                        setState(() {
                          savedWeight = weight;
                          savedHeight = height;
                          savedAge = age;
                          savedJob = job;
                          savedHours = hours;
                          savedDays = days;
                        });

                        // Clear input fields
                        _weightController.clear();
                        _heightController.clear();
                        _ageController.clear();
                        _jobController.clear();
                        _hoursController.clear();
                        _daysController.clear();

                        // Show a confirmation dialog
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

                  // Display saved information if any
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

                  // AI-generated Button
                  ElevatedButton(
                    onPressed: generateAIContent, // Call to generate AI content
                    child: const Text("Generate AI Data"),
                  ),
                  const SizedBox(height: 20),

                  // Display AI response
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

  // Function to generate AI content and classify the person based on BMI
  Future<void> generateAIContent() async {
    final weight = double.tryParse(savedWeight);
    final height = double.tryParse(savedHeight);

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      setState(() {
        aiResponse = "Invalid input. Please enter valid weight and height.";
      });
      return;
    }

    // Calculate BMI (Body Mass Index)
    double bmi = weight / ((height / 100) * (height / 100));

    // Generate the classification based on BMI
    String classification;
    if (bmi < 18.5) {
      classification = "Skinny";
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      classification = "Normal";
    } else {
      classification = "Fat";
    }

    // Set AI response
    setState(() {
      aiResponse = "Based on your BMI ($bmi), you are $classification.";
    });
  }
}
