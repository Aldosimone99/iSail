import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart'; // Import logging package
import 'screens/course_list_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/documents_screen.dart'; // Import DocumentsScreen
import 'screens/add_course_screen.dart'; // Import AddCourseScreen
import 'screens/logbook_screen.dart'; // Import LogbookScreen
import 'screens/countdown_screen.dart'; // Import CountdownScreen
import 'screens/news_screen.dart'; // Import NewsScreen
import 'widgets/custom_bottom_app_bar.dart'; // Import CustomBottomAppBar
import 'widgets/countdown_widget.dart'; // Import CountdownWidget
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart'; // Import localization package
import 'generated/l10n.dart'; // Import generated localization file

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final Logger _logger = Logger('MainLogger'); // Initialize logger

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      // Handle foreground notification
      _logger.info('Received local notification: $title - $body');
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title ?? ''),
          content: Text(body ?? ''),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      _logger.info('Notification selected with payload: ${notificationResponse.payload}'); // Debug log
      if (notificationResponse.payload != null) {
        _logger.info('Notification payload: ${notificationResponse.payload}'); // Debug log
      }
    },
  );

  tz.initializeTimeZones();

  // Request permissions for iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,  // Necessario su iOS
    statusBarBrightness: Brightness.dark, // Icone chiare su sfondo scuro
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      localizationsDelegates: [
        S.delegate, // Add localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales, // Add supported locales
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      home: WelcomeScreen(), // Always show WelcomeScreen on app start
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/documents': (context) => DocumentsScreen(),
        '/add_course': (context) => AddCourseScreen(onAddCourse: (course) {  },), // Add route for AddCourseScreen
        '/logbook': (context) => LogbookScreen(), // Add route for LogbookScreen
        '/countdown': (context) => CountdownScreen(), // Add route for CountdownScreen
        '/news': (context) => NewsScreen(), // Add route for NewsScreen
      },
    );
  }
}

class AppLocalizations {
  static var delegate;

  static of(BuildContext context) {}
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
      case '/documents': return 1;
      case '/countdown': return 2;
      case '/news': return 3; // Add NewsScreen index
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
          DocumentsScreen(),
          CountdownScreen(),
          NewsScreen(), // Add NewsScreen to PageView
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
                        color: Colors.blue.withAlpha((0.3 * 255).toInt()), // Circular background color
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
                  onDocumentsPressed: () => _onItemTapped(1),
                  onNewsPressed: () => _onItemTapped(3), // Add News callback
                  onLogbookPressed: () => _onItemTapped(5), // Updated
                  onCountdownPressed: () => _onItemTapped(2), // Updated
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
        title: Text(S.of(context).homeTitle), // Use localized string
      ),
      body: Center(
        child: CountdownWidget(),
      ),
    );
  }
}

void showNotification() async {
  var iOSDetails = DarwinNotificationDetails();
  var generalNotificationDetails = NotificationDetails(iOS: iOSDetails);

  await flutterLocalNotificationsPlugin.show(
      0, 'Titolo Notifica', 'Contenuto Notifica', generalNotificationDetails);
}
