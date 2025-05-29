import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';

import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/home.dart';

// Notifier global agar bisa diakses di seluruh widget
ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();

  // Ambil dark mode preference
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('darkMode') ?? false;
  isDarkMode.value = isDark;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'StaffLink',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: FutureBuilder<bool>(
            future: _checkFirstLaunch(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return const WelcomeScreen();
              }

              return const AuthChecker();
            },
          ),
        );
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return const LoginPage();
        } else {
          return const TaskManagerScreen(token: '');
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
