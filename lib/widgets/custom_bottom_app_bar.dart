import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onAnchorPressed;
  final VoidCallback onDocumentsPressed;

  const CustomBottomAppBar({
    super.key, // Convert 'key' to a super parameter
    required this.onAnchorPressed,
    required this.onDocumentsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return BottomAppBar(
      color: Color(0xFF181A1E), // Sfondo navbar
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.edit_document, "Documenti", context, isSelected: currentRoute == '/', onPressed: onDocumentsPressed), // Replaced Home with Courses
            _buildNavItem(Icons.store, "Centri", context),
            SizedBox(width: 50), // Spazio per il FAB
            _buildNavItem(Icons.search, "Cerca", context),
            _buildNavItem(Icons.settings, "Impostazioni", context, isSelected: currentRoute == '/settings'), // Replaced Profile with Settings
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, BuildContext context, {bool isSelected = false, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () {
        if (label == "Documenti" && ModalRoute.of(context)?.settings.name != '/') {
          Navigator.pushNamed(context, '/');
        } else if (label == "Impostazioni" && ModalRoute.of(context)?.settings.name != '/settings') {
          Navigator.pushNamed(context, '/settings');
        }
        // Add other navigation logic here if needed
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.white, size: 24),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}