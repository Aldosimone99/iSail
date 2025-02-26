import 'package:flutter/material.dart';
import 'package:isail/screens/course_list_screen.dart';
import 'dart:ui'; // Import for blur effect
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('userName') ?? '';
    setState(() {
      _usernameController.text = username;
    });
  }

  Future<void> _saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _usernameController.text);
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'change_username': isEnglish ? 'To change your username, enter the correct one here.' : 'Per cambiare il tuo username, inserisci qui quello corretto.',
      'save': isEnglish ? 'Save' : 'Salva',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false, // Remove back arrow
            backgroundColor: Colors.transparent, // Set AppBar background color to transparent
            elevation: 0, // Remove AppBar shadow
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
                child: Container(
                  color: Color(0xFF1C1C1E).withAlpha((0.5 * 255).toInt()), // Set semi-transparent background color
                ),
              ),
            ),
            title: Align(
              alignment: Alignment.centerLeft, // Align the title text to the left
              child: Text(
                'Account',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
              ),
            ),
            pinned: true,
            expandedHeight: 50.0, // Reduced height
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _getLocalizedText(context, 'change_username'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    focusNode: focusNode,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username', // Use hintText instead of labelText
                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'SF Pro'),
                      filled: true,
                      fillColor: Color(0xFF2C2C2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    style: TextStyle(color: Colors.white, fontFamily: 'SF Pro'),
                    onChanged: (value) {
                      // Handle username change
                    },
                    onTap: () {
                      // Hide the hint text when focused
                      focusNode.requestFocus();
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveUsername();
                      // Notify the CourseListScreen
                      final courseListScreenState = context.findAncestorStateOfType<CourseListScreenState>();
                      courseListScreenState?.updateUserName(_usernameController.text);
                      // Show confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Username aggiornato', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.black,
                        ),
                      );
                      // Clear the input field
                      _usernameController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(_getLocalizedText(context, 'save'), style: TextStyle(fontFamily: 'SF Pro')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
