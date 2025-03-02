import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onAnchorPressed;
  final VoidCallback onDocumentsPressed;
  final VoidCallback onLogbookPressed;
  final VoidCallback onCountdownPressed;
  final VoidCallback onNewsPressed; // Add News callback

  const CustomBottomAppBar({
    super.key,
    required this.onAnchorPressed,
    required this.onDocumentsPressed,
    required this.onLogbookPressed,
    required this.onCountdownPressed,
    required this.onNewsPressed, // Add News callback
  });

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'conventions': isEnglish ? 'Conventions' : 'Convenzioni',
      'countdown': isEnglish ? 'Countdown' : 'Countdown',
      'logbook': isEnglish ? 'Logbook' : 'Logbook',
      'news': isEnglish ? 'News' : 'Notizie', // Add News translation
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF181A1E),
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.edit_document, _getLocalizedText(context, 'conventions'), onDocumentsPressed),
            _buildNavItem(Icons.newspaper, _getLocalizedText(context, 'news'), onNewsPressed), // Add News icon and callback
            SizedBox(width: 50), // Spazio per il FloatingActionButton
            _buildNavItem(Icons.timer, _getLocalizedText(context, 'countdown'), onCountdownPressed),
            _buildNavItem(Icons.book, _getLocalizedText(context, 'logbook'), onLogbookPressed),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}