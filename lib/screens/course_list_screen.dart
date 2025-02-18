import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isail/screens/add_course_screen.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final List<Course> _courses = [];
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Utente';
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Buongiorno $userName';
    } else if (hour < 18) {
      _greeting = 'Buon Pomeriggio $userName';
    } else {
      _greeting = 'Buonasera $userName';
    }
    setState(() {});
  }

  void _addCourse(Course course) {
    setState(() {
      _courses.add(course);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting),
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return CourseCard(
            title: course.name,
            description: 'Scadenza: ${course.deadline.toLocal().toString().split(' ')[0]}',
            dueDate: course.deadline,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddCourseScreen(onAddCourse: _addCourse),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
