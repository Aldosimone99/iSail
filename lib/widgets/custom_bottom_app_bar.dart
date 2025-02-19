import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF181A1E), // Sfondo navbar
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.storefront, "Courses", context, isSelected: ModalRoute.of(context)?.settings.name == '/'), // Replaced Home with Courses
            _buildNavItem(Icons.search, "Search", context),
            SizedBox(width: 50), // Spazio per il FAB
            _buildNavItem(Icons.shopping_cart, "Cart", context),
            _buildNavItem(Icons.settings, "Settings", context, isSelected: ModalRoute.of(context)?.settings.name == '/settings'), // Replaced Profile with Settings
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, BuildContext context, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (label == "Courses" && ModalRoute.of(context)?.settings.name != '/') {
          Navigator.pushNamed(context, '/');
        } else if (label == "Settings" && ModalRoute.of(context)?.settings.name != '/settings') {
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
