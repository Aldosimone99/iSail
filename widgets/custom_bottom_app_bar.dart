import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onAnchorPressed;
  final VoidCallback onDocumentsPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onSearchPressed;

  const CustomBottomAppBar({
    super.key,
    required this.onAnchorPressed,
    required this.onDocumentsPressed,
    required this.onSettingsPressed,
    required this.onSearchPressed,
  });

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
            _buildNavItem(Icons.edit_document, "Convenzioni", onDocumentsPressed),
            _buildNavItem(Icons.store, "Centri", () {}),
            SizedBox(width: 50), // Spazio per il FloatingActionButton
            _buildNavItem(Icons.search, "Cerca", onSearchPressed),
            _buildNavItem(Icons.settings, "Impostazioni", onSettingsPressed),
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
