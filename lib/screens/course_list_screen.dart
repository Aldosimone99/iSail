import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:isail/screens/add_course_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz; // Import timezone package
import '../models/course.dart';
import '../widgets/course_card.dart';
import '../generated/l10n.dart';

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Add notification plugin instance
// Add a variable to store the selected language

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
    _loadSelectedLanguage(); // Load the selected language on init
    _scheduleDailyNotifications(); // Schedule daily notifications
    _scheduleWeeklyNotifications(); // Schedule weekly notifications
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

  String _getLocalizedText(BuildContext context, String key, {String? courseName}) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'goodMorning': isEnglish ? 'Good Morning' : 'Buongiorno',
      'goodAfternoon': isEnglish ? 'Good Afternoon' : 'Buon Pomeriggio',
      'goodEvening': isEnglish ? 'Good Evening' : 'Buonasera',
      'search': isEnglish ? 'Search' : 'Cerca',
      'sort': isEnglish ? 'Sort' : 'Ordina',
      'delete': isEnglish ? 'Delete' : 'Elimina',
      'cancel': isEnglish ? 'Cancel' : 'Annulla',
      'name': isEnglish ? 'Name' : 'Nome',
      'closestDeadline': isEnglish ? 'Closest Deadline' : 'Scadenza Vicina',
      'furthestDeadline': isEnglish ? 'Furthest Deadline' : 'Scadenza Lontana',
      'added': isEnglish ? 'Added' : 'Aggiunta',
      'confirmDeletion': isEnglish ? 'Confirm Deletion' : 'Conferma Eliminazione',
      'confirmDeletionMessage': isEnglish ? 'Are you sure you want to delete this course?' : 'Sei sicuro di voler eliminare questo corso?',
      'noCoursesAdded': isEnglish ? 'No Courses Added' : 'Nessun Corso Aggiunto',
      'due': isEnglish ? 'Due' : 'Scadenza',
      'courseExpiring': isEnglish ? 'Course Expiring' : 'Corso in Scadenza',
      'courseExpiringInDays': isEnglish ? 'The course "$courseName" will expire in a few days. Remember to renew it!' : 'Il corso "$courseName" scadrà tra pochi giorni. Ricordati di rinnovarlo!',
      'courseExpiringInMonths': isEnglish ? '$courseName will expire in a few months' : '$courseName scadrà tra pochi mesi',
    };
    return translations[key] ?? key;
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    final userName = _userNameNotifier.value;
    if (hour >= 6 && hour < 12) {
      _greeting = '${_getLocalizedText(context, 'goodMorning')} $userName';
    } else if (hour >= 12 && hour < 18) {
      _greeting = '${_getLocalizedText(context, 'goodAfternoon')} $userName';
    } else {
      _greeting = '${_getLocalizedText(context, 'goodEvening')} $userName';
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
    final course = _courses[index];
    _cancelNotificationsForCourse(course); // Cancel notifications for the course
    setState(() {
      _courses.removeAt(index);
      _saveCourses();
    });
  }

  void _cancelNotificationsForCourse(Course course) async {
    // Cancel daily notifications
    for (int i = 0; i <= 30; i++) {
      await flutterLocalNotificationsPlugin.cancel(course.id + i);
    }
    // Cancel weekly notifications
    for (int i = 0; i <= 6; i++) {
      await flutterLocalNotificationsPlugin.cancel(course.id + 1000 + i);
    }
    // Cancel monthly notifications
    for (int i = 1; i <= 12; i++) {
      await flutterLocalNotificationsPlugin.cancel(course.id + 2000 + i);
    }
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
            child: Text(_getLocalizedText(context, 'sort')), // Use localized string
            onPressed: () {
              Navigator.pop(context);
              _showOrderOptions(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(_getLocalizedText(context, 'delete')), // Use localized string
            onPressed: () {
              setState(() {
                _isDeleteMode = true;
              });
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(_getLocalizedText(context, 'cancel')), // Use localized string
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
            child: Text(_getLocalizedText(context, 'name')), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'name';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(_getLocalizedText(context, 'closestDeadline')), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_asc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(_getLocalizedText(context, 'furthestDeadline')), // Use localized string
            onPressed: () {
              setState(() {
                _sortCriteria = 'deadline_desc';
                _sortCourses();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(_getLocalizedText(context, 'added')), // Use localized string
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
          child: Text(_getLocalizedText(context, 'cancel')), // Use localized string
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

  void updateUserName(String userName) async {
    _userNameNotifier.value = userName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selectedLanguage') ?? 'en';
    setState(() {
      S.load(Locale(languageCode)); // Load the selected language
    });
  }

  void _scheduleDailyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('courses');
    if (coursesString != null) {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      final List<Course> courses = coursesJson.map((json) => Course.fromJson(json)).toList();

      final now = DateTime.now();
      final notificationTime = tz.TZDateTime.from(DateTime(now.year, now.month, now.day, 9), tz.local); // Schedule notifications for 9 AM

      for (var course in courses) {
        final daysRemaining = course.deadline.difference(now).inDays;
        if (daysRemaining > 0 && daysRemaining <= 30) {
          final iOSDetails = DarwinNotificationDetails();
          final platformDetails = NotificationDetails(iOS: iOSDetails);

          // Schedule daily notifications
          await flutterLocalNotificationsPlugin.zonedSchedule(
            course.id + daysRemaining, // Unique ID for each course
            _getLocalizedText(context, 'courseExpiring'), // Notification title
            _getLocalizedText(context, 'courseExpiringInDays', courseName: course.name), // Notification body
            notificationTime,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      }
    }
  }

  void _scheduleWeeklyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('courses');
    if (coursesString != null) {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      final List<Course> courses = coursesJson.map((json) => Course.fromJson(json)).toList();

      final now = DateTime.now();
      final notificationTime = tz.TZDateTime.from(DateTime(now.year, now.month, now.day, 9), tz.local); // Schedule notifications for 9 AM

      for (var course in courses) {
        final daysRemaining = course.deadline.difference(now).inDays;
        final monthsRemaining = daysRemaining ~/ 30;
        if (monthsRemaining > 0 && monthsRemaining <= 12) {
          final iOSDetails = DarwinNotificationDetails();
          final platformDetails = NotificationDetails(iOS: iOSDetails);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            course.id + monthsRemaining, // Unique ID for each course, offset to avoid conflicts with daily notifications
            _getLocalizedText(context, 'courseExpiring'), // Notification title
            _getLocalizedText(context, 'courseExpiringInMonths', courseName: course.name), // Notification body
            notificationTime,
            platformDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }
  }

  void _showChangeUsernameDialog() {
    final TextEditingController _usernameController = TextEditingController(text: _userNameNotifier.value);
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            isEnglish ? 'Change Username' : 'Cambia Nome Utente',
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0), // Add padding between title and input
            child: CupertinoTextField(
              controller: _usernameController,
              placeholder: isEnglish ? "Enter new username" : "Inserisci nuovo nome utente",
              placeholderStyle: TextStyle(color: Colors.grey), // Set placeholder text color to gray
              style: TextStyle(color: Colors.white), // Set input text color to white
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E), // Set fill color to dark gray
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(isEnglish ? 'Cancel' : 'Annulla', style: TextStyle(color: Colors.blue)), // Set button text color to blue
            ),
            CupertinoDialogAction(
              onPressed: () {
                updateUserName(_usernameController.text);
                Navigator.of(context).pop();
              },
              child: Text(isEnglish ? 'Save' : 'Salva', style: TextStyle(color: Colors.blue)), // Set button text color to blue
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
          child: GestureDetector(
            onTap: _showChangeUsernameDialog, // Show dialog on tap
            child: Text(
              _greeting,
              style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
            ),
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
                            hintText: _getLocalizedText(context, 'search'), // Use localized string
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
                              description: '${_getLocalizedText(context, 'due')}: ${DateFormat('dd/MM/yyyy').format(course.deadline)}', // Use localized string
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
                  _getLocalizedText(context, 'noCoursesAdded'), // Use localized string
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