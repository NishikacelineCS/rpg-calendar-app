import 'package:flutter/material.dart';
import 'rpg_calendar.dart'; // make sure this file exists in lib/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🌟 RPG Calendar',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark fantasy theme
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black87,
        fontFamily: 'Cinzel', // optional fantasy font
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
            fontSize: 22,
          ),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),
      ),
      home: const RpgCalendarDemo(), // ✅ correct name
    );
  }
}
