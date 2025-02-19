import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'screens/documents_screen.dart'; // Import DocumentsScreenn
import 'widgets/custom_bottom_app_bar.dart';

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
                bodyLarge: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                bodyMedium: TextStyle(color: Color(0xFFEBEBF5), fontFamily: 'SF Pro'), // Secondary Label
                headlineLarge: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                headlineMedium: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                titleMedium: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
                titleSmall: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'SF Pro'), // Label
              ),
              dividerColor: Color(0xFF38383A), // Separator
            ),
            home: HomeScreen(initialRoute: snapshot.data == true ? '/welcome' : '/'),
            routes: {
              '/settings': (context) => SettingsScreen(),
              '/documents': (context) => DocumentsScreen(), // Add DocumentsScreen route
            },
          );
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String initialRoute;

  const HomeScreen({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        initialRoute: initialRoute,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/welcome':
              page = WelcomeScreen();
              break;
            case '/settings':
              page = SettingsScreen();
              break;
            case '/documents':
              page = DocumentsScreen();
              break;
            default:
              page = CourseListScreen();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onAnchorPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to home screen
        },
        onDocumentsPressed: () {
          if (ModalRoute.of(context)?.settings.name != '/documents') {
            Navigator.pushNamed(context, '/documents'); // Navigate to documents screen
          }
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(77), // Replace withOpacity with withAlpha (77 is approximately 30% opacity)
            ),
          ),
          FloatingActionButton(
            heroTag: 'uniqueHeroTag', // Add unique heroTag
            backgroundColor: Colors.blue,
            shape: CircleBorder(),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to home screen
            },
            child: Icon(Icons.anchor, color: Colors.white, size: 30), // Replaced storefront icon with anchor icon
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
