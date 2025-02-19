import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Impostazioni',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SF Pro'), // Reduced font size
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
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
    );
  }

  Widget _buildSettingsSection(List<Widget> tiles) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
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