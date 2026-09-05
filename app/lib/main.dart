import 'package:flutter/material.dart';

import 'data/app_repositories.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';
import 'services/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await AppRepositories.initialize();

  final profile = await AppRepositories.profile.load();
  Session.nickname = profile?.nickname;
  final home = profile == null ? const WelcomeScreen() : const HomeScreen();
  runApp(MintonaryApp(home: home));
}

class MintonaryApp extends StatelessWidget {
  const MintonaryApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '민터너리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F3F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5379)),
      ),
      home: home,
    );
  }
}
