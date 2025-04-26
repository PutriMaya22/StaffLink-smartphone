import 'package:flutter/material.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'home.dart'; // Import halaman home

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/login_img.png', height: 180),
              SizedBox(height: 40),
              Text("Log-in", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: "Email", hintText: "Your email id"),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => ForgotPasswordPage())),
                  child: Text("Forget password?"),
                ),
              ),
              ElevatedButton(
               onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WalletScreen()),
                );
              },
                       child: Text("Login"),
                                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                    backgroundColor: Color(0xFF001F3F), // Warna navy
                  ),
                ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SignUpPage())),
                child: Text("Don’t have an account? Sign-up"),
              ),
              SizedBox(height: 10),
              Text("Or login with"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.mail, color: Colors.red)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.facebook, color: Colors.blue)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
