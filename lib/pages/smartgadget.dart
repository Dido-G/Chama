 import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SmartGadget extends StatefulWidget {
  const SmartGadget({Key? key}) : super(key: key);

  @override
  _SmartGadgetState createState() => _SmartGadgetState();
}

class _SmartGadgetState extends State<SmartGadget> {
  late WebSocketChannel channel;

  String time = "Waiting for data...";
  String acceleration = "Waiting for data...";
  String rotation = "Waiting for data...";
  String temperature = "Waiting for data...";
  String latitude = "Waiting for data...";
  String longitude = "Waiting for data...";
  String altitude = "Waiting for data...";

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.111:8080/'),
    );

    channel.stream.listen(
      (message) {
        if (mounted) {
          parseSensorData(message);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            time = "Error receiving data";
            acceleration = "Error";
            rotation = "Error";
            temperature = "Error";
            latitude = "Error";
            longitude = "Error";
            altitude = "Error";
          });
        }
      },
      onDone: () {
        if (mounted) {
          print("WebSocket connection closed. Reconnecting...");
          Future.delayed(Duration(seconds: 3), connectWebSocket);
        }
      },
    );
  }

  void parseSensorData(String message) {
    List<String> lines = message.split("\n");

    String acc = "", rot = "", temp = "", lat = "", lon = "", alt = "", t = "";

    for (String line in lines) {
      if (line.startsWith("Acceleration:")) {
        acc = line.replaceAll("Acceleration: ", "");
      } else if (line.startsWith("Rotation:")) {
        rot = line.replaceAll("Rotation: ", "");
      } else if (line.startsWith("Temperature:")) {
        temp = line.replaceAll("Temperature: ", "");
      } else if (line.startsWith("Latitude:")) {
        lat = line.replaceAll("Latitude: ", "");
      } else if (line.startsWith("Longtitude:")) {
        lon = line.replaceAll("Longtitude: ", "");
      } else if (line.startsWith("Altitude:")) {
        alt = line.replaceAll("Altitude: ", "");
      } else if (line.startsWith("Time:")) {
        t = line.replaceAll("Time: ", "");
      }
    }

    if (mounted) {
      setState(() {
        time = t;
        acceleration = acc;
        rotation = rot;
        temperature = temp;
        latitude = lat;
        longitude = lon;
        altitude = alt;
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Results'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSensorBox("Time", time, Icons.access_time),
            _buildSensorBox("Acceleration", acceleration, Icons.speed),
            _buildSensorBox("Rotation", rotation, Icons.sync),
            _buildSensorBox("Temperature", temperature, Icons.thermostat),
            _buildSensorBox("Latitude", latitude, Icons.map),
            _buildSensorBox("Longitude", longitude, Icons.map),
            _buildSensorBox("Altitude", altitude, Icons.terrain),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorBox(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 