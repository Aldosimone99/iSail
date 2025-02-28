import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:isail/screens/add_course_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import for notifications
import 'package:timezone/timezone.dart' as tz; // Import for timezone
import '../models/course.dart';
import '../widgets/course_card.dart';
import '../main.dart'; // Import the main.dart file to access the notification plugin
import '../generated/l10n.dart'; // Import for localization

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  CourseListScreenState createState() => CourseListScreenState();
}

class CourseListScreenState extends State<CourseListScreen> with SingleTickerProviderStateMixin {
  final List<Course> _courses = []; // Ensure this is defined
  String _greeting = '';
  String _searchQuery = '';
  String _sortCriteria = 'name';
  bool _isDeleteMode = false;
  AnimationController? _controller;
  final ValueNotifier<String> _userNameNotifier = ValueNotifier<String>('User'); // Add ValueNotifier
// Add a variable to store the selected language

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
    _loadSelectedLanguage(); // Load the selected language on init
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
    _userNameNotifier.addListener(_updateGreeting); // Add listener to update greeting when username changes
  }

  @override
  void dispose() {
    _controller?.dispose();
    _userNameNotifier.removeListener(_updateGreeting); // Remove listener when disposing
    super.dispose();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'User';
    _userNameNotifier.value = userName; // Update ValueNotifier
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    final userName = _userNameNotifier.value;
    if (hour >= 6 && hour < 12) {
      _greeting = '${S.of(context).goodMorning} $userName';
    } else if (hour >= 12 && hour < 18) {
      _greeting = '${S.of(context).goodAfternoon} $userName';
    } else {
      _greeting = '${S.of(context).goodEvening} $userName';
    }
    setState(() {});
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('courses');
    if (coursesString != null) {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      setState(() {
        _courses.addAll(coursesJson.map((json) => Course.fromJson(json)).toList());
      });
      _checkExpiringCourses(); // Ensure this is called after loading courses
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
            child: Text(S.of(context).sort), // Use localized string
            onPressed: () {
              Navigator.pop(context);
              _showOrderOptions(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(S.of(context).delete), // Use localized string
            onPressed: () {
              setState(() {
                _isDeleteMode = true;
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(S.of(context).cancel), // Use localized string
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
            child: Text(S.of(context).name), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'name';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(S.of(context).closestDeadline), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_asc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(S.of(context).furthestDeadline), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_desc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(S.of(context).added), // Use localized string
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
          child: Text(S.of(context).cancel), // Use localized string
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(S.of(context).confirmDeletion), // Use localized string
          content: Text(S.of(context).confirmDeletionMessage), // Use localized string
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel), // Use localized string
            ),
            CupertinoDialogAction(
              onPressed: () {
                _deleteCourse(index);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true,
              child: Text(S.of(context).delete), // Use localized string
            ),
          ],
        );
      },
    );
  }

  void _checkExpiringCourses() {
    final now = DateTime.now();
    for (var course in _courses) {
      final daysRemaining = course.deadline.difference(now).inDays;
      if (daysRemaining == 365 || daysRemaining == 182 || daysRemaining == 91 || daysRemaining == 30 || daysRemaining <= 30) {
        _scheduleNotification(
          id: course.hashCode,
          title: S.of(context).courseExpiring, // Use localized string
          body: _getLocalizedBody(course.name, daysRemaining), // Use localized string
          scheduledDate: _nextInstanceOfNineAM(),
        );
      }
    }
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9); // Change to 9 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleNotification({required int id, required String title, required String body, required tz.TZDateTime scheduledDate}) async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'locale': Localizations.localeOf(context).toString()}), // Pass locale information
    );
  }

  String _getLocalizedBody(String courseName, int daysRemaining) {
    if (daysRemaining > 30) {
      final monthsRemaining = (daysRemaining / 30).floor();
      return S.of(context).courseExpiringInMonths(courseName, monthsRemaining); // Use localized string for months
    } else {
      return S.of(context).courseExpiringInDays(courseName, daysRemaining); // Use localized string for days
    }
  }

  void updateUserName(String userName) {
    _userNameNotifier.value = userName;
  }


  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selectedLanguage') ?? 'en';
    setState(() {
      S.load(Locale(languageCode)); // Load the selected language
    });
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
              color: Color(0xFF1C1C1E).withAlpha(128), // Replace withOpacity with withAlpha (128 is approximately 50% opacity)
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the greeting text to the left
          child: Text(
            _greeting,
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
        actions: [
          // Remove the language change button
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isDeleteMode) {
            setState(() {
              _isDeleteMode = false;
            });
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: S.of(context).search, // Use localized string
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
                              color: Colors.black.withAlpha(51), // Replace withOpacity with withAlpha (51 is approximately 20% opacity)
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
                              description: '${S.of(context).due}: ${DateFormat('dd/MM/yyyy').format(course.deadline)}', // Use localized string
                              dueDate: course.deadline, // Ensure dueDate is passed correctly
                              course: course, // Pass the course object
                            ),
                            if (_isDeleteMode)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showDeleteConfirmationDialog(index),
                                  child: Container(
                                    width: 30, // Set smaller width
                                    height: 30, // Set smaller height
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
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
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_courses.isEmpty)
              Center(
                child: Text(
                  S.of(context).noCoursesAdded, // Use localized string
                  style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Set color to light gray
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
    super.key,
    required this.child,
    required this.controller,
    required this.enabled,
  });

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