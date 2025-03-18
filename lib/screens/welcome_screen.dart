import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import MainScreen
import '../generated/l10n.dart'; // Import generated localization file
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'dart:ui'; // Import for ImageFilter

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
    });
  }

  void _submitName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen(initialRoute: '/')),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen(initialRoute: '/')),
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'welcomeTitle': isEnglish ? 'Welcome to Mariner Hub' : 'Benvenuto su Mariner Hub',
      'welcomeSubtitle': isEnglish ? 'Enter your name to continue' : 'Inserisci il tuo nome per continuare',
      'name': isEnglish ? 'Name' : 'Nome',
      'continueButton': isEnglish ? 'Continue' : 'Continua',
      'hello': isEnglish ? 'Hello 👋' : 'Ciao 👋',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcome_background.png'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: _userName == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Align to the top
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 20), // Move content upwards
                      Text(
                        _getLocalizedText(context, 'welcomeTitle'), // Use localized string
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Title
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _getLocalizedText(context, 'welcomeSubtitle'), // Use localized string
                        style: TextStyle(fontSize: 18, color: Colors.white), // Subtitle
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 250, // Reduce the width of the input field
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            // Removed hintText
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitName,
                        child: Text(
                          _getLocalizedText(context, 'continueButton'), // Use localized string
                          style: TextStyle(color: Colors.black), // Changed text color to black
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start, // Align to the top
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$_userName', // Display the user name
                        style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold), // Title
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _getLocalizedText(context, 'hello'), // Use localized string
                        style: TextStyle(fontSize: 22, color: Colors.white), // Subtitle
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _navigateToHome,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 20, 145, 248).withAlpha((0.5 * 255).toInt()), // Darker circular background color
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...existing code...
      localizationsDelegates: [
        S.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales, // Add this line
      // ...existing code...
    );
  }
}
