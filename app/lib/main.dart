import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const MintonaryApp());
}

class MintonaryApp extends StatelessWidget {
  const MintonaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '민터너리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F3F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5379)),
      ),
      home: const LoginScreen(),
    );
  }
}
