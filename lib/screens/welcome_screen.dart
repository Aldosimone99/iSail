import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import MainScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();

  void _submitName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen(initialRoute: '/')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Make the AppBar black (OLED)
        title: Text(''), // Removed content
      ),
      // Removed BottomAppBar if it exists
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}
