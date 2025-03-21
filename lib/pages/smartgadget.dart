
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class SmartGadget extends StatefulWidget {
  const SmartGadget({Key? key}) : super(key: key);

  @override
  _SmartGadgetState createState() => _SmartGadgetState();
}

class _SmartGadgetState extends State<SmartGadget> {
  String time = "Loading...";
  String accelerationX = "Loading...";
  String accelerationY = "Loading...";
  String accelerationZ = "Loading...";
  String rotationX = "Loading...";
  String rotationY = "Loading...";
  String rotationZ = "Loading...";
  String temperature = "Loading...";
  String latitude = "Loading...";
  String longitude = "Loading...";
  String altitude = "Loading...";
  String aiResponse = "Awaiting AI feedback...";
  String combinedAcceleration = "Loading...";
  String location = "Loading...";
  String steps = "Loading...";
  String formStatus = "Checking..."; 

  final String sensorApiUrl = 'http://192.168.10.188:8080/api/sensor/latest';
  final String aiApiUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';

  Timer? _timer;
  TextEditingController promptController = TextEditingController();
  String apiKey = ""; 

  @override
  void initState() {
    super.initState();
    loadApiKey().then((_) {
      fetchSensorData(); 
      startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

 Future<void> loadApiKey() async {
  try {
    String apiKeyFromFile = await rootBundle.loadString('apiKey/key.txt');
    setState(() {
      apiKey = apiKeyFromFile.trim(); 
    });
  } catch (e) {
    print("Error loading API key: $e");
    setState(() {
      apiKey = "ERROR_LOADING_API_KEY"; 
    });
  }
}

  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        fetchSensorData();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> fetchSensorData() async {
    if (!mounted) return;

    try {
      
      final response = await http.get(Uri.parse(sensorApiUrl)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Error', 408),
          );

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            time = data['time'] ?? "N/A";
            accelerationX = data['acceleration_x'].toString();
            accelerationY = data['acceleration_y'].toString();
            accelerationZ = data['acceleration_z'].toString();
            rotationX = data['rotation_x'].toString();
            rotationY = data['rotation_y'].toString();
            rotationZ = data['rotation_z'].toString();
            temperature = "${data['temperature']}°C";
            latitude = data['latitude'].toString();
            longitude = data['longitude'].toString();
            altitude = data['altitude'].toString();
            steps = data['steps'].toString();

            double x = double.tryParse(accelerationX) ?? 0.0;
            double y = double.tryParse(accelerationY) ?? 0.0;
            double z = double.tryParse(accelerationZ) ?? 0.0;
            double magnitude = sqrt(x * x + y * y + z * z);
            combinedAcceleration = magnitude.toStringAsFixed(2);

            location = "Latitude: $latitude, Longitude: $longitude, Altitude: $altitude meters";

            formStatus = checkFormStatus(x, y, z);
          });
        }
      } else {
        setErrorState();
      }
    } catch (e) {
      setErrorState();
    }
  }

  String checkFormStatus(double x, double y, double z) {
    if (x > -1 && x < 1 && y >= -8 && y <= 8 && z > -1 && z < 1) {
      return "Form is Good ✅";
    } else {
      return "Form is Bad ❌";
    }
  }

  Future<void> sendToAI(String prompt) async {
    if (!mounted) return;

    final Uri uri = Uri.parse('$aiApiUrl?key=$apiKey');

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "User Query: $prompt\n\nSensor Data:\nTime: $time\nAcceleration X: $accelerationX\nAcceleration Y: $accelerationY\nAcceleration Z: $accelerationZ\nCombined Acceleration: $combinedAcceleration\nRotation X: $rotationX\nRotation Y: $rotationY\nRotation Z: $rotationZ\nTemperature: $temperature\nLatitude: $latitude\nLongitude: $longitude\nAltitude: $altitude\nSteps: $steps\n\nPlease provide a short response based on the sensor data."
                }
              ]
            }
          ]
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          aiResponse =
              data['candidates']?[0]['content']['parts'][0]['text'] ?? "No response from AI";
        });
      } else {
        setState(() {
          aiResponse = "Error getting AI response, Status Code: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        aiResponse = "AI request failed with error: $e";
      });
    }
  }

  void setErrorState() {
    if (!mounted) return;
    setState(() {
      time = "Error";
      accelerationX = "Error";
      accelerationY = "Error";
      accelerationZ = "Error";
      rotationX = "Error";
      rotationY = "Error";
      rotationZ = "Error";
      temperature = "Error";
      latitude = "Error";
      longitude = "Error";
      altitude = "Error";
      steps = "Error";
      formStatus = "Error";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE8C6B6),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Gadget Monitor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4), 
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF5E6E0),
      body: RefreshIndicator(
        onRefresh: fetchSensorData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSensorBox("Time", time, Icons.access_time),
            _buildAccelerationBox(),
            _buildRotationBox(),
            _buildSensorBox("Temperature", temperature, Icons.thermostat),
            _buildLocationBox(),
            _buildStepsBox(),
            _buildFormStatusBox(), 
            const SizedBox(height: 20),
            _buildTextInput(),
            _buildAIResponseBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchSensorData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSensorBox(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildAccelerationBox() => _buildSensorBox("Acceleration", "$accelerationX, $accelerationY, $accelerationZ", Icons.speed);
  Widget _buildRotationBox() => _buildSensorBox("Rotation", "$rotationX, $rotationY, $rotationZ", Icons.sync);
  Widget _buildLocationBox() => _buildSensorBox("Location", location, Icons.location_on);
  Widget _buildStepsBox() => _buildSensorBox("Steps", steps, Icons.directions_walk);

  Widget _buildFormStatusBox() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.accessibility, size: 36, color: formStatus.contains("Good") ? Colors.green : Colors.red),
        title: Text("Form Status", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(formStatus, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildTextInput() {
    return Column(
      children: [
        TextField(controller: promptController, decoration: const InputDecoration(hintText: "Enter your question for AI")),
        ElevatedButton(onPressed: () => sendToAI(promptController.text), child: const Text('Send to AI')),
      ],
    );
  }

  Widget _buildAIResponseBox() => _buildSensorBox("AI Response", aiResponse, Icons.chat);
}