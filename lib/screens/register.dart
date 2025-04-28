import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              Image.asset('assets/logo.png', height: 180),
              SizedBox(height: 20),
              Text(
                "Sign-up",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Password"),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: "Konfirmasi Password"),
              ),
               TextField(
                decoration: InputDecoration(labelText: "Department"), // <- Tambahan Department di sini
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF001F3F),
                  minimumSize: Size(double.infinity, 45),
                ),
                child: Text("Sign up"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back to login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
