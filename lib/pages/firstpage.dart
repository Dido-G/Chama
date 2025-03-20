// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app_test/pages/homePage.dart';
import 'package:app_test/pages/profilePage.dart';
import 'package:app_test/pages/settings_page.dart';
import 'package:flutter/material.dart';

class Firstpage extends StatefulWidget {
   Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
int set_index=0;

final List pages=[
Homepage(),SettingsPage(),Profilepage(),
];

void navigate(int index){
  setState(() {
    set_index=index;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text("title"),
      ),
      body: pages[set_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:set_index,
        onTap: navigate,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings"
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile"
            ),            
        ],
      ),
    );
  }
}