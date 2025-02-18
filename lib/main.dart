import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,  // Necessario su iOS
    statusBarBrightness: Brightness.dark, // Icone chiare su sfondo scuro
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') == null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return MaterialApp(
            title: 'iSail',
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black, // System Background (OLED black)
              colorScheme: ColorScheme.dark(
                primary: Colors.white, // Cambia il colore primario in bianco
                secondary: Colors.white, // Cambia il colore secondario in bianco
                surface: Color(0xFF2C2C2E), // Secondary Background
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Color(0xFFFFFFFF)), // Label
                bodyMedium: TextStyle(color: Color(0xFFEBEBF5)), // Secondary Label
                headlineLarge: TextStyle(color: Color(0xFFFFFFFF)), // Label
                headlineMedium: TextStyle(color: Color(0xFFFFFFFF)), // Label
                headlineSmall: TextStyle(color: Color(0xFFFFFFFF)), // Label
                titleLarge: TextStyle(color: Color(0xFFFFFFFF)), // Label
                titleMedium: TextStyle(color: Color(0xFFFFFFFF)), // Label
                titleSmall: TextStyle(color: Color(0xFFFFFFFF)), // Label
              ),
              dividerColor: Color(0xFF38383A), // Separator
            ),
            home: snapshot.data == true ? WelcomeScreen() : CourseListScreen(),
          );
        }
      },
    );
  }
}
