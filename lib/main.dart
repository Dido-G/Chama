import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/firstpage.dart';
import 'package:flutter_application_1/pages/homepage.dart';
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:flutter_application_1/pages/smartgadget.dart';
import 'package:flutter_application_1/pages/todoapp.dart';

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
