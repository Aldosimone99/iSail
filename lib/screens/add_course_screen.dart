import 'package:flutter/material.dart';
import '../models/course.dart';
import 'dart:ui'; // Add this import for ImageFilter

class AddCourseScreen extends StatefulWidget {
  final Function(Course) onAddCourse;

  const AddCourseScreen({super.key, required this.onAddCourse});

  @override
  // ignore: library_private_types_in_public_api
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final List<Course> _predefinedCourses = [
    Course(name: 'PSSR (Personal Safety and Social Responsibilities)', deadline: DateTime.now()),
    Course(name: 'Sopravvivenza e Salvataggio', deadline: DateTime.now()),
    Course(name: 'Antincendio di Base', deadline: DateTime.now()),
    Course(name: 'Primo Soccorso Elementare', deadline: DateTime.now()),
    Course(name: 'Security Awareness', deadline: DateTime.now()),
    Course(name: 'Antincendio Avanzato', deadline: DateTime.now()),
    Course(name: 'MAMS (Marittimo Abilitato ai Mezzi di Salvataggio)', deadline: DateTime.now()),
    Course(name: 'MABEV (Marittimo Abilitato ai Battelli di Emergenza Veloci)', deadline: DateTime.now()),
    Course(name: 'High Voltage', deadline: DateTime.now()),
    Course(name: 'IGF (International Gas Fuel)', deadline: DateTime.now()),
    Course(name: 'ECDIS (Electronic Chart Display and Information System)', deadline: DateTime.now()),
    Course(name: 'GMDSS (Global Maritime Distress and Safety System)', deadline: DateTime.now()),
    Course(name: 'Corsi Radar', deadline: DateTime.now()),
    Course(name: 'Security Duties', deadline: DateTime.now()),
    Course(name: 'Ship Security Officer (SSO)', deadline: DateTime.now()),
    Course(name: 'Crowd Management', deadline: DateTime.now()),
    Course(name: 'Crisis Management', deadline: DateTime.now()),
    Course(name: 'Leadership e Teamwork', deadline: DateTime.now()),
  ];

  Course? _selectedCourse;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  void _addCourse() {
    final name = _selectedCourse?.name ?? _nameController.text;
    final deadline = DateTime.parse(_deadlineController.text);
    final course = Course(name: name, deadline: deadline);
    widget.onAddCourse(course);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Allow any date
      lastDate: DateTime(2101), // Allow any date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue, // Set primary color for dark mode
              onPrimary: Colors.white, // Set text color on primary color for dark mode
              surface: Color(0xFF1C1C1E), // Set surface color for dark mode
              onSurface: Colors.white, // Set text color on surface color for dark mode
            ),
            dialogBackgroundColor: Color(0xFF1C1C1E), // Set dialog background color for dark mode
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _showPredefinedCoursesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1C1C1E), // Set dialog background color for dark mode
          title: Text('Seleziona un corso predefinito', style: TextStyle(color: Colors.white)), // Set title text color for dark mode
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predefinedCourses.length,
              itemBuilder: (BuildContext context, int index) {
                final course = _predefinedCourses[index];
                return ListTile(
                  title: Text(course.name, style: TextStyle(color: Colors.white)), // Set list item text color for dark mode
                  onTap: () {
                    setState(() {
                      _selectedCourse = course;
                      _nameController.text = course.name;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0, // Remove AppBar shadow
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
            child: Container(
              color: Color(0xFF1C1C1E).withOpacity(0.5), // Set semi-transparent background color
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            'Aggiungi Corso',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add the missing padding argument
          child: Column(
            mainAxisSize: MainAxisSize.min, // Center the content vertically
            children: [
              SizedBox(height: 20), // Add some space above the button
              ElevatedButton(
                onPressed: _showPredefinedCoursesDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button color for dark mode
                ),
                child: Text('Seleziona un corso predefinito'),
              ),
              SizedBox(height: 20), // Add some space below the button
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nome Corso',
                  filled: true,
                  fillColor: Color(0xFF2C2C2E), // Light gray color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                style: TextStyle(color: Colors.white), // Set text color for dark mode
              ),
              SizedBox(height: 20),
              TextField(
                controller: _deadlineController,
                decoration: InputDecoration(
                  hintText: 'Scadenza (YYYY-MM-DD)',
                  filled: true,
                  fillColor: Color(0xFF2C2C2E), // Light gray color
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white), // Set icon color for dark mode
                    onPressed: () => _selectDate(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                style: TextStyle(color: Colors.white), // Set text color for dark mode
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Set button color for dark mode
                ),
                child: Text('Aggiungi Corso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
