import 'package:flutter/material.dart';
import '../models/course.dart';
import '../screens/course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dueDate;
  final Course course; // Add course object

  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course, // Add course object
  });

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

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'due_in': isEnglish ? 'Due in' : 'Scade in',
      'expired': isEnglish ? 'Expired' : 'Scaduto',
      'due_today': isEnglish ? 'Due today' : 'Scade oggi',
      'year': isEnglish ? 'year' : 'anno',
      'years': isEnglish ? 'years' : 'anni',
      'month': isEnglish ? 'month' : 'mese',
      'months': isEnglish ? 'months' : 'mesi',
      'day': isEnglish ? 'day' : 'giorno',
      'days': isEnglish ? 'days' : 'giorni',
    };
    return translations[key] ?? key;
  }

  String _getCountdownText(BuildContext context) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return _getLocalizedText(context, 'expired');
    } else if (difference.inDays == 0) {
      return _getLocalizedText(context, 'due_today');
    } else if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      final remainingDays = difference.inDays % 365;
      final months = (remainingDays / 30).floor();
      final days = remainingDays % 30;
      return '${_getLocalizedText(context, 'due_in')} $years ${years == 1 ? _getLocalizedText(context, 'year') : _getLocalizedText(context, 'years')}${months > 0 ? ', $months ${months == 1 ? _getLocalizedText(context, 'month') : _getLocalizedText(context, 'months')}' : ''}${days > 0 ? ', $days ${days == 1 ? _getLocalizedText(context, 'day') : _getLocalizedText(context, 'days')}' : ''}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      final days = difference.inDays % 30;
      return '${_getLocalizedText(context, 'due_in')} $months ${months == 1 ? _getLocalizedText(context, 'month') : _getLocalizedText(context, 'months')}${days > 0 ? ', $days ${days == 1 ? _getLocalizedText(context, 'day') : _getLocalizedText(context, 'days')}' : ''}';
    } else {
      return '${_getLocalizedText(context, 'due_in')} ${difference.inDays} ${difference.inDays == 1 ? _getLocalizedText(context, 'day') : _getLocalizedText(context, 'days')}';
    }
  }

  double getTitleFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 375) {
      return 14; // Smaller font size for iPhone SE (3rd generation)
    } else if (screenWidth <= 414) {
      return 15; // Smaller font size for iPhone 16
    } else {
      return 17; // Default font size for larger devices
    }
  }

  double getDescriptionFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 375) {
      return 13; // Smaller font size for iPhone SE (3rd generation)
    } else if (screenWidth <= 414) {
      return 13; // Smaller font size for iPhone 16
    } else {
      return 15; // Default font size for larger devices
    }
  }

  double getPillFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 375) {
      return 13; // Smaller font size for iPhone SE (3rd generation)
    } else {
      return 15; // Default font size for larger devices
    }
  }

  EdgeInsets getPillPadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 375) {
      return EdgeInsets.symmetric(horizontal: 8, vertical: 4); // Smaller padding for iPhone SE (3rd generation)
    } else {
      return EdgeInsets.symmetric(horizontal: 10, vertical: 5); // Default padding for larger devices
    }
  }

  @override
  Widget build(BuildContext context) {
    final pillColor = _getPillColor();
    final borderColor = dueDate.isBefore(DateTime.now().add(Duration(days: 180))) 
        ? Colors.red 
        : (dueDate.isBefore(DateTime.now().add(Duration(days: 365))) 
            ? Color(0xFFF4C34D) 
            : Colors.green);
    final pillTextColor = dueDate.isBefore(DateTime.now().add(Duration(days: 180))) 
        ? Colors.red // Red text color for red boxes
        : (dueDate.isBefore(DateTime.now().add(Duration(days: 365))) 
            ? Color.fromARGB(255, 171, 130, 10) // Dark golden color for yellow boxes
            : borderColor);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add some horizontal margins
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()), // Remove the red shadow
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.2, // Increase the width and height of the rectangular card
          child: Card(
            color: _getBackgroundColor(), // Set the background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 3), // Increase border thickness
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Slightly increase padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: getTitleFontSize(context), // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: borderColor, // Set text color based on due date
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                  ),
                  SizedBox(height: 6), // Slightly increase spacing
                  Text(
                    description,
                    style: TextStyle(
                      color: borderColor, // Set text color based on due date
                      fontSize: getDescriptionFontSize(context), // Adjusted font size
                    ),
                  ),
                  Spacer(), // Push the countdown text to the bottom
                  Center(
                    child: Container(
                      padding: getPillPadding(context), // Adjusted padding
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      constraints: BoxConstraints(minWidth: 100), // Allow the pill to expand freely
                      child: Text(
                        _getCountdownText(context), // Pass context to _getCountdownText
                        style: TextStyle(
                          fontSize: getPillFontSize(context), // Adjusted font size
                          color: pillTextColor, // Set text color based on due date
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}