import 'package:flutter/material.dart';
import 'screens/welcome.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffLink',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(), 
    );
  }
}
