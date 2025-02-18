import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/course.dart';

class AddCourseScreen extends StatefulWidget {
  final Function(Course) onAddCourse;

  const AddCourseScreen({super.key, required this.onAddCourse});

  @override
  // ignore: library_private_types_in_public_api
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _showCalendar = false;

  void _submitData() {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final newCourse = Course(
      name: _nameController.text,
      deadline: _selectedDate!,
    );

    widget.onAddCourse(newCourse);
    Navigator.of(context).pop();
  }

  void _toggleCalendar() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Course'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Course Name'),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: _toggleCalendar,
            child: Text('Scadenza'),
          ),
          if (_showCalendar)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
            ),
          ElevatedButton(
            onPressed: _submitData,
            child: Text('Add Course'),
          ),
        ],
      ),
    );
  }
}
