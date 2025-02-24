import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logging/logging.dart'; // Import logging package
import '../main.dart'; // Import the main.dart file to access the notification plugin

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool _courseExpiryNotifications = false;
  final Logger _logger = Logger('NotificationsLogger'); // Initialize logger

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
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
            title: Text('Notifiche di scadenza dei corsi', style: TextStyle(color: Colors.white)),
            value: _courseExpiryNotifications,
            onChanged: (bool value) {
              setState(() {
                _courseExpiryNotifications = value;
              });
              if (value) {
                _scheduleCourseExpiryNotification();
              } else {
                _cancelCourseExpiryNotification();
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

  void _scheduleCourseExpiryNotification() async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Corso in scadenza',
      'Il tuo corso sta per scadere. Ricordati di completarlo!',
      platformChannelSpecifics,
    );
  }

  void _cancelCourseExpiryNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  void _sendTestNotification() async {
    _logger.info('Sending test notification'); // Debug log

    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Notifica di prova',
      'Questa è una notifica di prova.',
      platformChannelSpecifics,
    );

    _logger.info('Test notification sent'); // Debug log
  }
}
