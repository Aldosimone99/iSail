import 'package:flutter/material.dart';
import '../screens/course_list_screen.dart';

class CustomBottomAppBar extends StatelessWidget {
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
            _buildNavItem(Icons.storefront, "Courses", context, isSelected: true), // Replaced Home with Courses
            _buildNavItem(Icons.search, "Search", context),
            SizedBox(width: 50), // Spazio per il FAB
            _buildNavItem(Icons.shopping_cart, "Cart", context),
            _buildNavItem(Icons.settings, "Settings", context), // Replaced Profile with Settings
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, BuildContext context, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (label == "Courses") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CourseListScreen()),
          );
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
