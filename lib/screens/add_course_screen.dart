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
          title: Text('Seleziona un corso predefinito'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predefinedCourses.length,
              itemBuilder: (BuildContext context, int index) {
                final course = _predefinedCourses[index];
                return ListTile(
                  title: Text(course.name),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showPredefinedCoursesDialog,
              child: Text('Seleziona un corso predefinito'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome Corso'),
            ),
            TextField(
              controller: _deadlineController,
              decoration: InputDecoration(
                labelText: 'Scadenza (YYYY-MM-DD)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCourse,
              child: Text('Aggiungi Corso'),
            ),
          ],
        ),
      ),
    );
  }
}
