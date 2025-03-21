import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/firstpage.dart';
import 'package:flutter_application_1/pages/homepage.dart';
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:flutter_application_1/pages/smartgadget.dart';
import 'package:flutter_application_1/pages/todoapp.dart';
/*import 'package:google_generative_ai/google_generative_ai.dart';
void main()async {
  runApp(const MyApp());
  final model=GenerativeModel(model: 'gemini-2.0-flash', apiKey: 'AIzaSyCaftS-mHf18T4HD4wcrY4LfJrA85OXic8');
  final content=[Content.text('tell a joke')];
  final response=await  model.generateContent(content);
  print(response.text);
}*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Firstpage(),
      routes: {
        '/firstpage':(context)=>Firstpage(),
        '/homepage':(context)=>Homepage(),
        '/smartsgadget':(context)=>SmartGadget(),
        '/tasks':(context)=>TodoApp(),
        '/profilepage':(context)=>Profilepage()
      },
    );
  }
}
