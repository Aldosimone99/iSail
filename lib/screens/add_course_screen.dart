import 'package:flutter/material.dart';
import '../models/course.dart';

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
        title: Text('Aggiungi Corso'),
        backgroundColor: Color(0xFF1C1C1E), // Set AppBar background color for dark mode
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add the missing padding argument
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showPredefinedCoursesDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set button color for dark mode
              ),
              child: Text('Seleziona un corso predefinito'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome Corso',
                labelStyle: TextStyle(color: Colors.white), // Set label text color for dark mode
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Set border color for dark mode
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // Set focused border color for dark mode
                ),
              ),
              style: TextStyle(color: Colors.white), // Set text color for dark mode
            ),
            SizedBox(height: 20),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Scadenza (YYYY-MM-DD)',
                labelStyle: TextStyle(color: Colors.white), // Set label text color for dark mode
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white), // Set icon color for dark mode
                  onPressed: () => _selectDate(context),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Set border color for dark mode
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // Set focused border color for dark mode
                ),
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
    );
  }
}
