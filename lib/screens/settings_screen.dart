import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart';

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
            _buildSettingsTile('Stile', CupertinoIcons.paintbrush, const Color.fromARGB(255, 255, 255, 255)),
            _buildSettingsTile('Spazio e Dati', CupertinoIcons.folder, const Color.fromARGB(255, 255, 255, 255)),
            _buildSettingsTile('Backup', CupertinoIcons.cloud_upload, const Color.fromARGB(255, 255, 255, 255)),
          ]),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onAnchorPressed: () {
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to home screen
          }
        },
        onDocumentsPressed: () {
          // Do nothing
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
              color: Colors.blue.withOpacity(0.3), // Effetto alone
            ),
          ),
          FloatingActionButton(
            heroTag: 'uniqueHeroTag', // Add unique heroTag
            backgroundColor: Colors.blue,
            shape: CircleBorder(),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to home screen
              }
            },
            child: Icon(Icons.anchor, color: Colors.white, size: 30), // Replaced storefront icon with anchor icon
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  Widget _buildSettingsTile(String title, IconData icon, Color iconColor, {String? subtitle, Widget? trailing}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title, style: TextStyle(color: Colors.white, fontFamily: 'SF Pro')),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey, fontFamily: 'SF Pro')) : null,
          trailing: trailing ?? Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 20),
          onTap: () {},
        ),
        Divider(color: Colors.grey.shade800, height: 1, thickness: 0.5),
      ],
    );
  }
}