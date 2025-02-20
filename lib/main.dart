import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'screens/documents_screen.dart'; // Import DocumentsScreen
import 'screens/add_course_screen.dart'; // Import AddCourseScreen
import 'screens/logbook_screen.dart'; // Import LogbookScreen
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
            title: 'SailSafe',
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Color(0xFF000000), // Change background color to OLED black
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent, // Set AppBar background color to transparent
                elevation: 0, // Remove AppBar shadow
                titleTextStyle: TextStyle(color: Colors.blue, fontFamily: 'SF Pro', fontSize: 20), // Change text color to blue
                iconTheme: IconThemeData(color: Colors.black), // Set AppBar icon color to black
              ),
              colorScheme: ColorScheme.dark(
                primary: Colors.white, // Cambia il colore primario in bianco
                secondary: Colors.white, // Cambia il colore secondario in bianco
                surface: Color.fromARGB(255, 255, 255, 255), // Secondary Background
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
            home: MainScreen(initialRoute: snapshot.data == true ? '/welcome' : '/'),
            routes: {
              '/welcome': (context) => WelcomeScreen(),
              '/settings': (context) => SettingsScreen(),
              '/documents': (context) => DocumentsScreen(),
              '/add_course': (context) => AddCourseScreen(onAddCourse: (course) {  },), // Add route for AddCourseScreen
              '/logbook': (context) => LogbookScreen(), // Add route for LogbookScreen
            },
          );
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final String initialRoute;

  const MainScreen({super.key, required this.initialRoute});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _getPageIndex(widget.initialRoute));
  }

  int _getPageIndex(String route) {
    switch (route) {
      case '/welcome': return 0;
      case '/settings': return 1;
      case '/documents': return 2;
      default: return 3;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
          });
        },
        physics: NeverScrollableScrollPhysics(),
        children: [
          WelcomeScreen(),
          SettingsScreen(),
          DocumentsScreen(),
          CourseListScreen(),
          LogbookScreen(), // Add LogbookScreen to PageView
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withAlpha(77), // Semi-transparent blue background
        ),
        padding: EdgeInsets.all(8), // Add padding to create space around the button
        child: FloatingActionButton(
          heroTag: 'uniqueAnchorButton', // Provide a unique tag
          onPressed: () => _onItemTapped(3),
          backgroundColor: Colors.blue,
          shape: CircleBorder(), // Make the button circular
          child: Icon(Icons.anchor),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        onAnchorPressed: () => _onItemTapped(3),
        onDocumentsPressed: () => _onItemTapped(2),
        onSettingsPressed: () => _onItemTapped(1),
        onLogbookPressed: () => _onItemTapped(4), // Updated
      ),
    );
  }
}
