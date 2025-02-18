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
  String _searchQuery = '';

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
    final filteredCourses = _courses.where((course) {
      return course.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Make the AppBar black (OLED)
        title: Text(
          _greeting,
          style: TextStyle(fontSize: 24), // Increase the font size
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca corsi...',
                filled: true,
                fillColor: Color(0xFF2C2C2E), // Light gray color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // Make the borders more rounded
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return CourseCard(
                  title: course.name,
                  description: 'Scadenza: ${course.deadline.toLocal().toString().split(' ')[0]}',
                  dueDate: course.deadline,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(), // Make the button round
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
