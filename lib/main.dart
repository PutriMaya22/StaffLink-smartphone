// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/login.dart';
// import 'screens/home.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'StaffLink',
//       debugShowCheckedModeBanner: false,
//       home: FutureBuilder(
//         future: SharedPreferences.getInstance(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final token = snapshot.data!.getString('auth_token');
//             return token == null ? const LoginPage() : const TaskManagerScreen();
//           }
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'package:sp_util/sp_util.dart';
import 'screens/welcome.dart'; 
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
          
          // If it's first launch or no token exists
          if (snapshot.data == true) {
            return const WelcomeScreen();
          }
          
          // If not first launch, check authentication
          return _AuthChecker();
        },
      ),
    );
  }
}

class _AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final token = snapshot.data!.getString('auth_token');
          return token == null ? const LoginPage() : const TaskManagerScreen();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
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