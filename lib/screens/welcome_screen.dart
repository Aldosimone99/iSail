import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Import for blur effect
import '../main.dart'; // Import MainScreen

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcome_background.jpg'), // Path to your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 300, // Set a fixed width to make the box narrower
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black.withOpacity(0.5),
                  child: _userName == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Benvenuto su SailSafe',
                              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Title
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Inserisci il tuo nome per continuare',
                              style: TextStyle(fontSize: 18, color: Colors.white), // Subtitle
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: 'Nome'),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitName,
                              child: Text(
                                'Continua',
                                style: TextStyle(color: Colors.black), // Changed text color to black
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Bentornato su SailSafe $_userName',
                              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Title
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
                                  color: Colors.blue.withOpacity(0.3), // Circular background color
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
