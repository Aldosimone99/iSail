import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'account_screen.dart'; // Import the AccountScreen
import 'dart:ui'; // Import for blur effect

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Ensure this method does not cause excessive state updates
    // or infinite loops
    setState(() {
      // Update state only if necessary
    });
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'settings': isEnglish ? 'Settings' : 'Impostazioni',
      'search': isEnglish ? 'Search...' : 'Cerca...',
      'account': isEnglish ? 'Account' : 'Account',
      'language': isEnglish ? 'Language' : 'Lingua',
      'storage_data': isEnglish ? 'Storage and Data' : 'Spazio e Dati',
      'backup': isEnglish ? 'Backup' : 'Backup',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false, // Remove the back arrow
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
                _getLocalizedText(context, 'settings'),
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
              ),
            ),
            pinned: true,
            expandedHeight: 50.0, // Match the height with DocumentsScreen
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _getLocalizedText(context, 'search'),
                        filled: true,
                        fillColor: Color(0xFF2C2C2E), // Light gray color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onChanged: (value) {
                        // Handle search query change
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSettingsSection([
            _buildSettingsTile(_getLocalizedText(context, 'account'), CupertinoIcons.person, const Color.fromARGB(255, 249, 248, 248), onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(),
                ),
              );
            }),
            _buildSettingsTile(_getLocalizedText(context, 'language'), CupertinoIcons.globe, const Color.fromARGB(255, 255, 255, 255), onTap: () {
              // Handle language selection
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(List<Widget> tiles) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Increased vertical padding
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: tiles),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color iconColor, {String? subtitle, Widget? trailing, void Function()? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: TextStyle(color: Colors.white, fontFamily: 'SF Pro')),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey, fontFamily: 'SF Pro')) : null,
          trailing: trailing ?? Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 20),
          onTap: onTap,
        ),
        Divider(color: Colors.grey.shade800, height: 1, thickness: 0.5),
      ],
    );
  }
}