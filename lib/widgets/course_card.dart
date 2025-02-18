import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dueDate;

  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  Color _getBorderColor() {
    final now = DateTime.now();
    if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Colors.redAccent; // Neon red for due within a year
    } else {
      return Colors.blueAccent; // Blue for due after a year
    }
  }

  Color _getBackgroundColor() {
    final now = DateTime.now();
    if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Colors.red.withAlpha(50); // Light red background for due within a year
    } else {
      return Colors.blue.withAlpha(50); // Light blue background for due after a year
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBackgroundColor(), // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getBorderColor(), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Color(0xFFEBEBF5)),
            ),
          ],
        ),
      ),
    );
  }
}