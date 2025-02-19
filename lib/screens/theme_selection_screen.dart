import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sfondo scuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
          alignment: Alignment.bottomLeft, // Align title to the bottom left
          child: Padding(
            padding: EdgeInsets.only(left: 16, bottom: 0), // Increase bottom padding to move text down
            child: Text(
              'Seleziona Tema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SF Pro'), // Reduced font size
            ),
          ),
        ),
        centerTitle: false, // Ensure title is not centered
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Match padding with SettingsScreen
        child: Column(
          children: [
            _buildThemeTile('Tema Chiaro', onTap: () {
              // Handle light theme selection
            }),
            _buildThemeTile('Tema Scuro', onTap: () {
              // Handle dark theme selection
            }),
            _buildThemeTile('Tema di Sistema', onTap: () {
              // Handle system theme selection
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(String title, {void Function()? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E), // Apply gray color to the tile
        borderRadius: BorderRadius.circular(10), // Match border radius with SettingsScreen
      ),
      margin: EdgeInsets.symmetric(vertical: 5), // Add vertical margin between tiles
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: TextStyle(color: Colors.white, fontFamily: 'SF Pro')),
            trailing: Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 20),
            onTap: onTap,
          ),
          Divider(color: Colors.grey.shade800, height: 1, thickness: 0.5),
        ],
      ),
    );
  }
}
