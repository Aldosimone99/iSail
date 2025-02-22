import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  DateTime? _endDate;
  String _countdownMessage = 'Seleziona le date di fine imbarco';

  @override
  void initState() {
    super.initState();
    _loadEndDate();
  }

  Future<void> _loadEndDate() async {
    final prefs = await SharedPreferences.getInstance();
    final endDateString = prefs.getString('endDate');
    if (endDateString != null) {
      setState(() {
        _endDate = DateTime.parse(endDateString);
        _updateCountdownMessage();
      });
    }
  }

  void _updateCountdownMessage() {
    if (_endDate != null) {
      final now = DateTime.now();
      if (now.isAfter(_endDate!)) {
        _countdownMessage = 'L\'imbarco è già terminato';
      } else {
        final remainingDays = _endDate!.difference(now).inDays;
        _countdownMessage = 'Mancano $remainingDays giorni';
      }
    } else {
      _countdownMessage = 'Seleziona le date di fine imbarco';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Countdown',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            _countdownMessage,
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
