import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/course.dart';
import 'dart:ui'; // Import for blur effect
import 'dart:math'; // Import for generating random ID

class AddCourseScreen extends StatefulWidget {
  final Function(Course) onAddCourse;

  const AddCourseScreen({super.key, required this.onAddCourse});

  @override
  AddCourseScreenState createState() => AddCourseScreenState(); // Change _AddCourseScreenState to AddCourseScreenState
}

class AddCourseScreenState extends State<AddCourseScreen> { // Change _AddCourseScreenState to AddCourseScreenState
  final List<Course> _predefinedCourses = [
    Course(id: Random().nextInt(1000000), name: 'PSSR (Personal Safety and Social Responsibilities)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Survival and Rescue', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Basic Firefighting', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Elementary First Aid', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Security Awareness', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Advanced Firefighting', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'MAMS (Able Seafarer Lifeboat)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'MABEV (Able Seafarer Fast Rescue Boats)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'High Voltage', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'IGF (International Gas Fuel)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'ECDIS (Electronic Chart Display and Information System)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'GMDSS (Global Maritime Distress and Safety System)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Radar Courses', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Security Duties', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Ship Security Officer (SSO)', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Crowd Management', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Crisis Management', deadline: DateTime.now()),
    Course(id: Random().nextInt(1000000), name: 'Leadership and Teamwork', deadline: DateTime.now()),
  ];

  Course? _selectedCourse;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  void _addCourse() {
    if (_nameController.text.isEmpty || _deadlineController.text.isEmpty) return;
    final name = _selectedCourse?.name ?? _nameController.text;
    final deadline = DateTime.parse(_deadlineController.text);
    final id = Random().nextInt(1000000); // Generate a random ID
    final course = Course(id: id, name: name, deadline: deadline); // Include the ID in the Course object
    widget.onAddCourse(course);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Color(0xFF1C1C1E),
          child: Column(
            children: [
              Expanded( // Wrap CupertinoDatePicker with Expanded
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _deadlineController.text = newDateTime.toLocal().toString().split(' ')[0];
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('OK', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPredefinedCoursesDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(_getLocalizedText(context, 'select_course')),
        actions: _predefinedCourses.map((course) {
          return CupertinoActionSheetAction(
            child: Text(course.name),
            onPressed: () {
              setState(() {
                _selectedCourse = course;
                _nameController.text = course.name;
              });
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(_getLocalizedText(context, 'cancel')),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'add_course': isEnglish ? 'Add Course' : 'Aggiungi Corso',
      'select_predefined_course': isEnglish ? 'Select a Predefined Course' : 'Seleziona un corso predefinito',
      'course_name': isEnglish ? 'Course Name' : 'Nome Corso',
      'deadline': isEnglish ? 'Deadline (YYYY-MM-DD)' : 'Scadenza (YYYY-MM-DD)',
      'select_course': isEnglish ? 'Select a Course' : 'Seleziona un corso',
      'cancel': isEnglish ? 'Cancel' : 'Annulla',
      'ok': isEnglish ? 'OK' : 'OK',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // OLED black background
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Color(0xFF1C1C1E).withAlpha(128), // Replace withOpacity with withAlpha (128 is approximately 50% opacity)
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getLocalizedText(context, 'add_course'),
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea( // Wrap SingleChildScrollView with SafeArea
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            clipBehavior: Clip.none, // Ignore overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showPredefinedCoursesDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_getLocalizedText(context, 'select_predefined_course')),
                ),
                SizedBox(height: 20),
                _buildTextField(_nameController, _getLocalizedText(context, 'course_name')),
                SizedBox(height: 20),
                _buildTextField(_deadlineController, _getLocalizedText(context, 'deadline'),
                    isDateField: true, context: context),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_getLocalizedText(context, 'add_course')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isDateField = false, BuildContext? context}) {
    return TextField(
      controller: controller,
      readOnly: isDateField,
      onTap: isDateField ? () => _selectDate(context!) : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Color(0xFF2C2C2E),
        suffixIcon: isDateField
            ? Icon(Icons.calendar_today, color: Colors.white)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}