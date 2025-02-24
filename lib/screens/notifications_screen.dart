import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math'; // Import for random selection
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logging/logging.dart'; // Import logging package
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package
import 'dart:convert'; // Import for JSON encoding/decoding
import '../main.dart'; // Import the main.dart file to access the notification plugin
import '../models/course.dart'; // Import the Course model

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool _yearlyNotifications = false;
  bool _monthlyNotifications = false;
  bool _weeklyNotifications = false;
  bool _dailyNotifications = false;
  final Logger _logger = Logger('NotificationsLogger'); // Initialize logger
  List<Course> _courses = []; // List of courses
  int _notificationCount = 0; // Counter for notifications

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadSettings();
    _loadCourses();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yearlyNotifications = prefs.getBool('yearlyNotifications') ?? false;
      _monthlyNotifications = prefs.getBool('monthlyNotifications') ?? false;
      _weeklyNotifications = prefs.getBool('weeklyNotifications') ?? false;
      _dailyNotifications = prefs.getBool('dailyNotifications') ?? false;
    });
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesString = prefs.getString('courses');
    if (coursesString != null) {
      final List<dynamic> coursesJson = jsonDecode(coursesString);
      setState(() {
        _courses = coursesJson.map((json) => Course.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('yearlyNotifications', _yearlyNotifications);
    await prefs.setBool('monthlyNotifications', _monthlyNotifications);
    await prefs.setBool('weeklyNotifications', _weeklyNotifications);
    await prefs.setBool('dailyNotifications', _dailyNotifications);
  }

  Future<void> _updateBadgeCount() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.setBadgeCount(_notificationCount);
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
              color: Color(0xFF1C1C1E).withAlpha((0.5 * 255).toInt()), // Set semi-transparent background color
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            'Notifiche',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notifiche ad un anno della scadenza', style: TextStyle(color: Colors.white)),
            value: _yearlyNotifications,
            onChanged: (bool value) {
              setState(() {
                _yearlyNotifications = value;
              });
              _saveSettings();
              if (value) {
                _scheduleYearlyNotifications();
              } else {
                _cancelYearlyNotifications();
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
          SwitchListTile(
            title: Text('Notifiche mensili entro 6 mesi dalla scadenza', style: TextStyle(color: Colors.white)),
            value: _monthlyNotifications,
            onChanged: (bool value) {
              setState(() {
                _monthlyNotifications = value;
              });
              _saveSettings();
              if (value) {
                _scheduleMonthlyNotifications();
              } else {
                _cancelMonthlyNotifications();
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
          SwitchListTile(
            title: Text('Notifiche settimanali entro 3 mesi dalla scadenza', style: TextStyle(color: Colors.white)),
            value: _weeklyNotifications,
            onChanged: (bool value) {
              setState(() {
                _weeklyNotifications = value;
              });
              _saveSettings();
              if (value) {
                _scheduleWeeklyNotifications();
              } else {
                _cancelWeeklyNotifications();
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
          SwitchListTile(
            title: Text('Notifiche giornaliere entro 1 mese dalla scadenza', style: TextStyle(color: Colors.white)),
            value: _dailyNotifications,
            onChanged: (bool value) {
              setState(() {
                _dailyNotifications = value;
              });
              _saveSettings();
              if (value) {
                _scheduleDailyNotifications();
              } else {
                _cancelDailyNotifications();
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade700,
          ),
          ListTile(
            title: Text('Invia notifica di prova', style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.send, color: Colors.white),
            onTap: _sendTestNotification,
          ),
        ],
      ),
    );
  }

  void _scheduleYearlyNotifications() async {
    for (var course in _courses) {
      final daysRemaining = course.deadline.difference(DateTime.now()).inDays;
      if (daysRemaining == 365) {
        _logger.info('Scheduling yearly notification for course: ${course.name}, expiring in $daysRemaining days'); // Debug log
        await _scheduleNotification(
          id: course.hashCode,
          title: 'Corso in scadenza',
          body: 'Il corso "${course.name}" sta per scadere tra un anno. Ricordati di completarlo!',
          scheduledDate: _nextInstanceOfEightAM(),
          daysRemaining: daysRemaining,
        );
      }
    }
  }

  void _scheduleMonthlyNotifications() async {
    final List<int> intervals = [182, 152, 121, 91, 60, 30]; // Days remaining for 6, 5, 4, 3, 2, 1 months

    for (var course in _courses) {
      final daysRemaining = course.deadline.difference(DateTime.now()).inDays;
      if (intervals.contains(daysRemaining)) {
        _logger.info('Scheduling monthly notification for course: ${course.name}, expiring in $daysRemaining days'); // Debug log
        await _scheduleNotification(
          id: course.hashCode,
          title: 'Corso in scadenza',
          body: 'Il corso "${course.name}" sta per scadere tra $daysRemaining giorni. Ricordati di completarlo!',
          scheduledDate: _nextInstanceOfEightAM(),
          daysRemaining: daysRemaining,
        );
      }
    }
  }

  void _scheduleWeeklyNotifications() async {
    for (var course in _courses) {
      final daysRemaining = course.deadline.difference(DateTime.now()).inDays;
      if (daysRemaining <= 91 && daysRemaining % 7 == 0) {
        _logger.info('Scheduling weekly notification for course: ${course.name}, expiring in $daysRemaining days'); // Debug log
        await _scheduleNotification(
          id: course.hashCode,
          title: 'Corso in scadenza',
          body: 'Il corso "${course.name}" sta per scadere tra $daysRemaining giorni. Ricordati di completarlo!',
          scheduledDate: _nextInstanceOfEightAM(),
          daysRemaining: daysRemaining,
        );
      }
    }
  }

  void _scheduleDailyNotifications() async {
    for (var course in _courses) {
      final daysRemaining = course.deadline.difference(DateTime.now()).inDays;
      if (daysRemaining <= 30) {
        _logger.info('Scheduling daily notification for course: ${course.name}, expiring in $daysRemaining days'); // Debug log
        await _scheduleNotification(
          id: course.hashCode + daysRemaining, // Ensure unique ID for each notification
          title: 'Corso in scadenza',
          body: 'Il corso "${course.name}" sta per scadere tra $daysRemaining giorni. Ricordati di completarlo!',
          scheduledDate: _nextInstanceOfTenTwentyPM(), // Ensure correct method is called
          daysRemaining: daysRemaining,
        );
      }
    }
  }

  tz.TZDateTime _nextInstanceOfEightAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTenTwentyPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22, 34);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleNotification({required int id, required String title, required String body, required tz.TZDateTime scheduledDate, required int daysRemaining}) async {
    _logger.info('Scheduling notification: $title - $body at $scheduledDate'); // Debug log
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
      matchDateTimeComponents: DateTimeComponents.time, // Ensure daily notifications
    );

    setState(() {
      _notificationCount++;
    });
    await _updateBadgeCount();
  }

  void _cancelYearlyNotifications() async {
    for (var course in _courses) {
      await flutterLocalNotificationsPlugin.cancel(course.hashCode);
    }
    setState(() {
      _notificationCount = 0;
    });
    await _updateBadgeCount();
  }

  void _cancelMonthlyNotifications() async {
    for (var course in _courses) {
      await flutterLocalNotificationsPlugin.cancel(course.hashCode);
    }
    setState(() {
      _notificationCount = 0;
    });
    await _updateBadgeCount();
  }

  void _cancelWeeklyNotifications() async {
    for (var course in _courses) {
      await flutterLocalNotificationsPlugin.cancel(course.hashCode);
    }
    setState(() {
      _notificationCount = 0;
    });
    await _updateBadgeCount();
  }

  void _cancelDailyNotifications() async {
    for (var course in _courses) {
      await flutterLocalNotificationsPlugin.cancel(course.hashCode);
    }
    setState(() {
      _notificationCount = 0;
    });
    await _updateBadgeCount();
  }

  void _sendTestNotification() async {
    _logger.info('Sending test notification'); // Debug log

    final random = Random();
    final course = _courses[random.nextInt(_courses.length)];
    final duration = Duration(days: random.nextInt(365)); // Random duration up to 1 year
    final daysRemaining = duration.inDays;

    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Notifica di prova',
      'Il corso "${course.name}" sta per scadere tra $daysRemaining giorni. Ricordati di rinnovarlo!',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 20)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _notificationCount++;
    });
    await _updateBadgeCount();

    _logger.info('Test notification scheduled for course: ${course.name}, expiring in $daysRemaining days'); // Debug log
  }
}

extension on IOSFlutterLocalNotificationsPlugin? {
  setBadgeCount(int notificationCount) {}
}
