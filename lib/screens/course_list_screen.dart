import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  String _sortCriteria = 'name';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
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

  void _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('courses');
    if (coursesString != null) {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      setState(() {
        _courses.addAll(coursesJson.map((json) => Course.fromJson(json)).toList());
      });
    }
  }

  void _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String coursesString = jsonEncode(_courses.map((course) => course.toJson()).toList());
    await prefs.setString('courses', coursesString);
  }

  void _addCourse(Course course) {
    setState(() {
      _courses.add(course);
      _saveCourses();
    });
  }

  void _editCourse(int index, Course course) {
    setState(() {
      _courses[index] = course;
      _saveCourses();
    });
  }

  void _deleteCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _saveCourses();
    });
  }

  void _sortCourses() {
    setState(() {
      if (_sortCriteria == 'name') {
        _courses.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortCriteria == 'deadline_asc') {
        _courses.sort((a, b) => a.deadline.compareTo(b.deadline));
      } else if (_sortCriteria == 'deadline_desc') {
        _courses.sort((a, b) => b.deadline.compareTo(a.deadline));
      } else if (_sortCriteria == 'added') {
        // Assuming courses are added in order, no need to sort
      }
    });
  }

  void _showSortOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text('Nome'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'name';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Scadenza vicina'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_asc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Scadenza lontana'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_desc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Aggiunta'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'added';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Annulla'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditCourseDialog(int index) {
    final course = _courses[index];
    final nameController = TextEditingController(text: course.name);
    final deadlineController = TextEditingController(text: course.deadline.toLocal().toString().split(' ')[0]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifica Corso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome Corso'),
              ),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: 'Scadenza (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          deadlineController.text = picked.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                final editedCourse = Course(
                  name: nameController.text,
                  deadline: DateTime.parse(deadlineController.text),
                );
                _editCourse(index, editedCourse);
                Navigator.of(context).pop();
              },
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Conferma Eliminazione'),
          content: Text('Sei sicuro di voler eliminare questo corso?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annulla'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                _deleteCourse(index);
                Navigator.of(context).pop();
              },
              child: Text('Elimina'),
              isDestructiveAction: true,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _courses.where((course) {
      return course.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Make the AppBar black (OLED)
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _greeting,
              style: TextStyle(fontSize: 24), // Increase the font size
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E), // Same color as the search bar
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.swap_vert), // Use up and down arrows icon
                onPressed: () => _showSortOptions(context),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca...',
                filled: true,
                fillColor: Color(0xFF2C2C2E), // Light gray color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                return Dismissible(
                  key: Key(course.name),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _showDeleteConfirmationDialog(index);
                      return false;
                    } else {
                      _showEditCourseDialog(index);
                      return false;
                    }
                  },
                  child: Container(
                    width: double.infinity, // Ensure the course card occupies the entire width
                    child: CourseCard(
                      title: course.name,
                      description: 'Scadenza: ${course.deadline.toLocal().toString().split(' ')[0]}',
                      dueDate: course.deadline,
                    ),
                  ),
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
