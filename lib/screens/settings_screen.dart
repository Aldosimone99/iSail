import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'theme_selection_screen.dart'; // Import the ThemeSelectionScreen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sfondo scuro
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            pinned: true,
            expandedHeight: 70.0, // Reduced height
            automaticallyImplyLeading: false, // Remove back arrow
            flexibleSpace: FlexibleSpaceBar(
              title: Align(
                alignment: Alignment.bottomLeft, // Align title to the bottom left
                child: Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 0), // Increase bottom padding to move text down
                  child: Text(
                    'Impostazioni',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SF Pro'), // Reduced font size
                  ),
                ),
              ),
              centerTitle: false, // Ensure title is not centered
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Reduced padding
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cerca...',
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
          ),
          _buildSettingsSection([
            _buildSettingsTile('Account', CupertinoIcons.person, const Color.fromARGB(255, 249, 248, 248)),
            _buildSettingsTile('Stile', CupertinoIcons.paintbrush, const Color.fromARGB(255, 255, 255, 255), onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemeSelectionScreen(),
                ),
              );
            }),
            _buildSettingsTile('Spazio e Dati', CupertinoIcons.folder, const Color.fromARGB(255, 255, 255, 255)),
            _buildSettingsTile('Backup', CupertinoIcons.cloud_upload, const Color.fromARGB(255, 255, 255, 255)),
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