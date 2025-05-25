import 'package:flutter/material.dart';
import 'package:sp_util/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'screens/welcome.dart';
import 'screens/login.dart'; // Pastikan file ini ada
import 'screens/home.dart'; // Pastikan file ini ada

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // WAJIB!
  await SpUtil.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StaffLink',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If it's first launch
          if (snapshot.data == true) {
            return const WelcomeScreen();
          }

          // If not first launch, check authentication using SpUtil
          return const AuthChecker();
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(), // Use SpUtil to get the token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return const LoginPage(); // Navigate to LoginPage if no token
        } else {
          return const TaskManagerScreen(token: ''); // Navigate to TaskManagerScreen if token exists
          // Perhatikan: Anda mungkin perlu mengambil data pengguna lain di sini
          // dan mengirimkannya ke TaskManagerScreen.
        }
      },
    );
  }

  Future<String?> _getToken() async {
    return SpUtil.getString('auth_token');
  }
}

Future<bool> _checkFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;

  if (isFirstLaunch) {
    await prefs.setBool('first_launch', false);
    return true;
  }
  return false;
}