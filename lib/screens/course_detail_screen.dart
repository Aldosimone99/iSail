import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // Import for blur effect
import '../models/course.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  Color _getCircleColor() {
    final now = DateTime.now();
    if (course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Color(0xFFFEE9E8); // Light red background for due within 6 months
    } else if (course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFFDF5D5); // Light yellow background for due between 6 months and a year
    } else {
      return Color(0xFFE0F7F1); // Light green background for due after a year
    }
  }

  Color _getBorderColor() {
    final now = DateTime.now();
    if (course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Colors.red; // Red for due within 6 months
    } else if (course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFF4C34D); // Yellow for due between 6 months and a year
    } else {
      return Colors.green; // Green for due after a year
    }
  }

  Color _getTextColor() {
    final now = DateTime.now();
    if (course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Colors.red; // Red text color for red boxes
    } else if (course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color.fromARGB(255, 171, 130, 10); // Dark golden color for yellow boxes
    } else {
      return Colors.green; // Green text color for green boxes
    }
  }

  String _getDaysRemaining() {
    final now = DateTime.now();
    final difference = course.deadline.difference(now);
    if (difference.isNegative) {
      return 'Scaduto';
    } else {
      return '${difference.inDays} giorni';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0, // Remove AppBar shadow
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
            child: Container(
              color: Color(0xFF1C1C1E).withAlpha(128), // Replace withOpacity with withAlpha (128 is approximately 50% opacity)
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            course.name,
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
        actions: [
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50), // Add space above the circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _getCircleColor(),
                shape: BoxShape.circle,
                border: Border.all(color: _getBorderColor(), width: 3), // Add border
              ),
              child: Center(
                child: Text(
                  _getDaysRemaining(),
                  style: TextStyle(fontSize: 24, color: _getTextColor(), fontWeight: FontWeight.bold), // Use the same text color
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Scadenza:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(DateFormat('dd/MM/yyyy').format(course.deadline)),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
