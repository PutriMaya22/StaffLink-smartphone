import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/forgot_img.png', height: 180),
              SizedBox(height: 20),
              Text("Forgot password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Email", hintText: "Your email id"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  backgroundColor: Color(0xFF001F3F),
                ),
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
