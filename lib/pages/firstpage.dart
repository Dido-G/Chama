// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:flutter_application_1/pages/homepage.dart';
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:flutter_application_1/pages/smartgadget.dart';
import 'package:flutter_application_1/pages/todoapp.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  int set_index = 0;

  final List pages = [
    Homepage(),
    SmartGadget(),
    
    TodoApp(),
     Profilepage(),
  ];

  void navigate(int index) {
    setState(() {
      set_index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    /*  appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text("Title"),
      ),*/
      body: pages[set_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: set_index,
        onTap: navigate,
        selectedItemColor: Colors.deepPurple, // Highlighted icon color
        unselectedItemColor: Colors.grey, // Other icons' color
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.light),
            label: "SmartGadget",
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: "Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
