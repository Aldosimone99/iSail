import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  CountdownWidgetState createState() => CountdownWidgetState();
}

class CountdownWidgetState extends State<CountdownWidget> {
  DateTime? _endDate;
  String _countdownMessage = '';

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
    } else {
      _updateCountdownMessage();
    }
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'select_end_date': isEnglish ? 'Select the end date of the embarkation' : 'Seleziona le date di fine imbarco',
      'embarkation_ended': isEnglish ? 'The embarkation has already ended' : 'L\'imbarco è già terminato',
      'days_remaining': isEnglish ? 'days remaining' : 'giorni',
      'countdown': isEnglish ? 'Countdown' : 'Countdown',
    };
    return translations[key] ?? key;
  }

  void _updateCountdownMessage() {
    if (_endDate != null) {
      final now = DateTime.now();
      if (now.isAfter(_endDate!)) {
        _countdownMessage = _getLocalizedText(context, 'embarkation_ended');
      } else {
        final remainingDays = _endDate!.difference(now).inDays;
        _countdownMessage = '${_getLocalizedText(context, 'days_remaining')}: $remainingDays';
      }
    } else {
      _countdownMessage = _getLocalizedText(context, 'select_end_date');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.3 * 255).toInt()),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getLocalizedText(context, 'countdown'),
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
