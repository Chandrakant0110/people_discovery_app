import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:people_discovery_app/firebase_options.dart';
import 'package:people_discovery_app/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[App] Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[App] Firebase initialized successfully');
  debugPrint('[App] Starting application...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People Discovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // AuthWrapper handles routing based on authentication state
      home: const AuthWrapper(),
    );
  }
}
