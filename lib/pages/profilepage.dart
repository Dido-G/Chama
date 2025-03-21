import 'package:flutter/material.dart';

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

  // Variables to hold the saved information
  String savedWeight = '';
  String savedHeight = '';
  String savedAge = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Information"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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

                        // Save the data and update UI
                        setState(() {
                          savedWeight = weight;
                          savedHeight = height;
                          savedAge = age;
                        });

                        // Clear input fields
                        _weightController.clear();
                        _heightController.clear();
                        _ageController.clear();

                        // Show a confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Profile Saved"),
                              content: Text(
                                  "Weight: $weight kg\nHeight: $height cm\nAge: $age years"),
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
                  if (savedWeight.isNotEmpty && savedHeight.isNotEmpty && savedAge.isNotEmpty)
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
}
