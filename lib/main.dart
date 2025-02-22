import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/settings_screen.dart'; // Import SettingsScreen
import 'screens/documents_screen.dart'; // Import DocumentsScreen
import 'screens/add_course_screen.dart'; // Import AddCourseScreen
import 'screens/logbook_screen.dart'; // Import LogbookScreen
import 'screens/countdown_screen.dart'; // Import CountdownScreen
import 'widgets/custom_bottom_app_bar.dart';
import 'widgets/countdown_widget.dart'; // Import CountdownWidget

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SailSafe', // Changed app name
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
      home: WelcomeScreen(), // Always show WelcomeScreen on app start
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/documents': (context) => DocumentsScreen(),
        '/add_course': (context) => AddCourseScreen(onAddCourse: (course) {  },), // Add route for AddCourseScreen
        '/logbook': (context) => LogbookScreen(), // Add route for LogbookScreen
        '/countdown': (context) => CountdownScreen(), // Add route for CountdownScreen
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
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _getPageIndex(widget.initialRoute));
    _currentPage.value = _getPageIndex(widget.initialRoute);
  }

  int _getPageIndex(String route) {
    switch (route) {
      case '/welcome': return 0;
      case '/settings': return 1;
      case '/documents': return 2;
      case '/countdown': return 3; // Add CountdownScreen index
      default: return 4;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentPage.value = index;
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
            _currentPage.value = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
        children: [
          WelcomeScreen(),
          SettingsScreen(),
          DocumentsScreen(),
          CountdownScreen(), // Add CountdownScreen to PageView
          CourseListScreen(),
          LogbookScreen(), // Add LogbookScreen to PageView
        ],
      ),
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, pageIndex, child) {
          return pageIndex == 0
              ? SizedBox.shrink()
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.3), // Circular background color
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: 'uniqueAnchorButton', // Provide a unique tag
                      onPressed: () => _onItemTapped(4),
                      backgroundColor: Colors.blue,
                      shape: CircleBorder(), // Make the button circular
                      child: Icon(Icons.anchor),
                    ),
                  ],
                );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, pageIndex, child) {
          return pageIndex == 0
              ? SizedBox.shrink()
              : CustomBottomAppBar(
                  onAnchorPressed: () => _onItemTapped(4),
                  onDocumentsPressed: () => _onItemTapped(2),
                  onSettingsPressed: () => _onItemTapped(1),
                  onLogbookPressed: () => _onItemTapped(5), // Updated
                  onCountdownPressed: () => _onItemTapped(3), // Add Countdown callback
                );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iSail Home'),
      ),
      body: Center(
        child: CountdownWidget(),
      ),
    );
  }
}
