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
      return Colors.red.withAlpha(50); // Light red background for due within 6 months
    } else if (dueDate.isBefore(now.add(Duration(days: 365)))) {
      return Colors.yellow.withAlpha(50); // Light yellow background for due between 6 months and a year
    } else {
      return Colors.blue.withAlpha(50); // Light blue background for due after a year
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
    final pillColor = _getBorderColor().withOpacity(0.2);
    
    return Card(
      color: _getBackgroundColor(), // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getBorderColor(), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(maxWidth: 150), // Constrain the width of the pill
              child: Text(
                _getCountdownText(),
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}