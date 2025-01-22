import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Import the Login Screen
import 'register_screen.dart'; // Import the Register Screen
import 'home_screen.dart'; // Import the HomeScreen
import 'ver_progresso_screen.dart'; // Import the Ver Progresso Screen
import 'criar_progresso_screen.dart'; // Import the Criar Progresso Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        // Set the background color to black for the app's primary theme
        scaffoldBackgroundColor: Colors.black,  // Make the entire scaffold background black
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,  // Black app bar background
          titleTextStyle: TextStyle(color: Colors.green.shade400), // Green title in AppBar
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // White text on black background
          bodyMedium: TextStyle(color: Colors.white), // White text on black background
          titleMedium: TextStyle(color: Colors.green.shade400), // Green headings
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,  // Green background for buttons
            foregroundColor: Colors.black,  // Black text on buttons
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.7),  // Black background for input fields
          labelStyle: TextStyle(color: Colors.green.shade400), // Green label text
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade400), // Green borders
          ),
        ),
      ),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.data == true) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/verprogresso': (context) => VerProgressoScreen(),
        '/criarprogresso': (context) => CriarProgressoScreen(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return token != null;
  }
}
