// import 'package:flutter/material.dart';
// import 'register.dart';
// import 'forgot_password.dart';
// import 'home.dart'; 

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 60),
//                 Image.asset(
//                   'assets/logo.png',
//                   height: 150,
//                   width: 150,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Log-in",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 const TextField(
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     hintText: "Your email id",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 const TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     hintText: "Password",
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.visibility_off),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed:
//                         () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const ForgotPasswordPage(),
//                           ),
//                         ),
//                     child: const Text("Forget password?"),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) =>
//                                 const TaskManagerScreen(), // pastikan ini ada di home.dart
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 45),
//                     backgroundColor: const Color(0xFF001F3F),
//                   ),
//                   child: const Text("Login"),
//                 ),
//                 const SizedBox(height: 15),
//                 TextButton(
//                   onPressed:
//                       () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const SignUpPage()),
//                       ),
//                   child: const Text("Don't have an account? Sign-up"),
//                 ),
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'home.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login'), // Replace with your actual API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('user_data', jsonEncode(responseData['user']));

        // Navigate to home screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskManagerScreen(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Login failed';
          if (responseData['errors'] != null && responseData['errors']['email'] != null) {
            _errorMessage = responseData['errors']['email'][0];
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Log-in",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Your email id",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    ),
                    child: const Text("Forget password?"),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: const Color(0xFF001F3F),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  ),
                  child: const Text("Don't have an account? Sign-up"),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}