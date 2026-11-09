import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_state.dart';
import 'screens/auth_screen.dart';
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Study First - Home'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => appState.logout(),
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Home (later)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Logged in as: ${user.username} (${user.campus})'),
                    const SizedBox(height: 8),
                    Text('Favorite subjects: ${user.favoriteSubjects.join(', ')}'),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => appState.logout(),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
