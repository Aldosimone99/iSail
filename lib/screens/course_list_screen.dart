import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui'; // Import for blur effect
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:isail/screens/add_course_screen.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> with SingleTickerProviderStateMixin {
  final List<Course> _courses = [];
  String _greeting = '';
  String _searchQuery = '';
  String _sortCriteria = 'name';
  bool _isDeleteMode = false;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Utente';
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _greeting = 'Buongiorno $userName';
    } else if (hour >= 12 && hour < 18) {
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
            child: Text('Ordina'),
            onPressed: () {
              Navigator.pop(context);
              _showOrderOptions(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Elimina'),
            onPressed: () {
              setState(() {
                _isDeleteMode = true;
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

  void _showOrderOptions(BuildContext context) {
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


  @override
  Widget build(BuildContext context) {
    final filteredCourses = _courses.where((course) {
      return course.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
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
          alignment: Alignment.centerLeft, // Align the greeting text to the left
          child: Text(
            _greeting,
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isDeleteMode) {
            setState(() {
              _isDeleteMode = false;
            });
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
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
                  SizedBox(width: 8), // Add some space between the search bar and the button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color to white
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black), // Use three dots icon and set color to black
                      onPressed: () => _showSortOptions(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two cards per row
                  crossAxisSpacing: 0.0, // Increase horizontal spacing between cards
                  mainAxisSpacing: 0.0, // Increase vertical spacing between cards
                  childAspectRatio: 1.2, // Adjust aspect ratio for larger rectangular cards
                ),
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  return ShakeTransition(
                    controller: _controller,
                    enabled: _isDeleteMode,
                    child: Stack(
                      children: [
                        CourseCard(
                          title: course.name,
                          description: 'Scadenza: ${DateFormat('dd/MM/yyyy').format(course.deadline)}',
                          dueDate: course.deadline,
                        ),
                        if (_isDeleteMode)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 30, // Set smaller width
                              height: 30, // Set smaller height
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(Icons.close, color: Colors.red, size: 18), // Center the icon
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

class ShakeTransition extends StatelessWidget {
  final Widget child;
  final AnimationController? controller;
  final bool enabled;

  const ShakeTransition({
    Key? key,
    required this.child,
    required this.controller,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        return Transform.rotate(
          angle: enabled ? 0.02 * controller!.value : 0.0, // Rotate slightly to mimic iOS shake
          child: child,
        );
      },
      child: child,
    );
  }
}
