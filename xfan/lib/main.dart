import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';


void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xFan',
      theme: ThemeData(
        brightness: Brightness.dark, // Using dark theme as per our design
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        // Add more theme customization here
      ),
      home: const MainScreen(), // We'll create this next
    );
  }
}