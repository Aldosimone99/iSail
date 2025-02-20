import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'screens/documents_screen.dart'; // Import DocumentsScreen
import 'screens/add_course_screen.dart'; // Import AddCourseScreen
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
              '/add_course': (context) => AddCourseScreen(onAddCourse: (Course ) {  },), // Add route for AddCourseScreen
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
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _getPageIndex(widget.initialRoute));
  }

  int _getPageIndex(String route) {
    switch (route) {
      case '/welcome':
        return 0;
      case '/settings':
        return 1;
      case '/documents':
        return 2;
      default:
        return 3;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => SettingsScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DocumentsScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => CourseListScreen(),
              );
            },
          ),
        ],
        physics: NeverScrollableScrollPhysics(), // Disable swipe gesture
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onAnchorPressed: () {
          _onItemTapped(3); // Navigate to home screen
        },
        onDocumentsPressed: () {
          _onItemTapped(2); // Navigate to documents screen
        },
        onSettingsPressed: () {
          _onItemTapped(1); // Navigate to settings screen
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
              _onItemTapped(3); // Navigate to home screen
            },
            child: Icon(Icons.anchor, color: Colors.white, size: 30), // Replaced storefront icon with anchor icon
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NoSwipePageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final List<Widget> children;

  const NoSwipePageView({
    required this.controller,
    required this.onPageChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      physics: NeverScrollableScrollPhysics(), // Disable swipe gesture
    );
  }
}
