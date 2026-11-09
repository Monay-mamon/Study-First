import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';

void main() {
  runApp(const StudyFirstApp());
}

class StudyFirstApp extends StatelessWidget {
  const StudyFirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Study First',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AppRoot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        if (user == null) {
          return const AuthScreen();
        } else if (!user.profileComplete) {
          return const ProfileSetupScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
