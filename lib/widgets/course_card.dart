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
    if (dueDate.isBefore(now.add(Duration(days: 180)))) {
      return Colors.redAccent; // Neon red for due within 6 months
    } else if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Colors.yellowAccent; // Yellow for due between 6 months and a year
    } else {
      return Colors.blueAccent; // Blue for due after a year
    }
  }

  Color _getBackgroundColor() {
    final now = DateTime.now();
    if (dueDate.isBefore(now.add(Duration(days: 180)))) {
      return Color(0xFFFEE9E8); // Light red background for due within 6 months
    } else if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFFDF5D5); // Light yellow background for due between 6 months and a year
    } else {
      return Color(0xFFE0F7F1); // Light green background for due after a year
    }
  }

  Color _getPillColor() {
    final now = DateTime.now();
    if (dueDate.isBefore(now.add(Duration(days: 180)))) {
      return Colors.red.withAlpha(50); // Light red for due within 6 months
    } else if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFF4C34D).withAlpha(50); // Light yellow for due between 6 months and a year
    } else {
      return Colors.green.withAlpha(50); // Light green for due after a year
    }
  }

  String _getCountdownText() {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    if (difference.isNegative) {
      return 'Scaduto';
    } else if (difference.inDays == 0) {
      return 'Scade oggi';
    } else if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      final remainingDays = difference.inDays % 365;
      final months = (remainingDays / 30).floor();
      final days = remainingDays % 30;
      return 'Scade in $years anni${months > 0 ? ', $months mesi' : ''}${days > 0 ? ', $days giorni' : ''}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      final days = difference.inDays % 30;
      return 'Scade in $months mesi${days > 0 ? ', $days giorni' : ''}';
    } else {
      return 'Scade in ${difference.inDays} giorni';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillColor = _getPillColor();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add some horizontal margins
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Remove the red shadow
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        color: _getBackgroundColor(), // Set the background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Remove the colored border
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Slightly increase padding
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: dueDate.isBefore(DateTime.now().add(Duration(days: 180))) ? Colors.red : (dueDate.isBefore(DateTime.now().add(Duration(days: 365))) ? Color(0xFFF4C34D) : Colors.green), // Set text color based on due date
                      ),
                    ),
                    SizedBox(height: 6), // Slightly increase spacing
                    Text(
                      description,
                      style: TextStyle(
                        color: dueDate.isBefore(DateTime.now().add(Duration(days: 180))) ? Colors.red : (dueDate.isBefore(DateTime.now().add(Duration(days: 365))) ? Color(0xFFF4C34D) : Colors.green), // Set text color based on due date
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Slightly increase padding
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: BoxConstraints(maxWidth: 130), // Slightly increase the width of the pill
                child: Text(
                  _getCountdownText(),
                  style: TextStyle(
                    fontSize: 15,
                    color: dueDate.isBefore(DateTime.now().add(Duration(days: 180))) ? Colors.red : (dueDate.isBefore(DateTime.now().add(Duration(days: 365))) ? Color(0xFFF4C34D) : Colors.green), // Set text color based on due date
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}