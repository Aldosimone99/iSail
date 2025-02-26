import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  CountdownScreenState createState() => CountdownScreenState();
}

class CountdownScreenState extends State<CountdownScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _countdownMessage = '';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString('startDate');
    final endDateString = prefs.getString('endDate');
    if (startDateString != null && endDateString != null) {
      setState(() {
        _startDate = DateTime.parse(startDateString);
        _endDate = DateTime.parse(endDateString);
        _updateCountdownMessage();
      });
    } else {
      _updateCountdownMessage();
    }
  }

  Future<void> _saveDates() async {
    final prefs = await SharedPreferences.getInstance();
    if (_startDate != null && _endDate != null) {
      await prefs.setString('startDate', _startDate!.toIso8601String());
      await prefs.setString('endDate', _endDate!.toIso8601String());
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    if (isStartDate && _startDate != null) {
      initialDate = _startDate!;
    } else if (!isStartDate && _endDate != null) {
      initialDate = _endDate!;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Color(0xFF1C1C1E),
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Brightness.dark,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      initialDateTime: initialDate,
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          if (isStartDate) {
                            _startDate = newDate;
                          } else {
                            _endDate = newDate;
                          }
                          _updateCountdownMessage();
                          _saveDates(); // Automatically save dates when changed
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetDates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startDate');
    await prefs.remove('endDate');
    setState(() {
      _startDate = null;
      _endDate = null;
      _countdownMessage = _getLocalizedText(context, 'select_start_end_dates');
    });
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'select_start_end_dates': isEnglish ? 'Select the start and end dates of the embarkation' : 'Seleziona le date di inizio e fine imbarco',
      'embarkation_not_started': isEnglish ? 'Embarkation not started' : 'Imbarco non iniziato',
      'embarkation_completed': isEnglish ? 'Embarkation completed, welcome back home🏠' : 'Imbarco completato, bentornato a casa🏠',
      'days_remaining': isEnglish ? 'days remaining' : 'giorni',
      'countdown': isEnglish ? 'Countdown' : 'Countdown',
      'start': isEnglish ? 'Start' : 'Inizio',
      'end': isEnglish ? 'End' : 'Fine',
      'edit': isEnglish ? 'Edit' : 'Modifica',
      'start_date': isEnglish ? 'Start Date' : 'Data di inizio',
      'end_date': isEnglish ? 'End Date' : 'Data di fine',
      'total_days': isEnglish ? 'Total days' : 'Giorni totali',
      'error_start_after_end': isEnglish ? 'Error: the start date is after the end date' : 'Errore: la data di inizio imbarco è successiva alla data di fine imbarco',
    };
    return translations[key] ?? key;
  }

  void _updateCountdownMessage() {
    if (_startDate != null && _endDate != null) {
      final now = DateTime.now();
      if (now.isBefore(_startDate!)) {
        _countdownMessage = _getLocalizedText(context, 'embarkation_not_started');
      } else if (now.isAfter(_endDate!)) {
        _countdownMessage = _getLocalizedText(context, 'embarkation_completed');
      } else {
        final remainingDays = _endDate!.difference(now).inDays + 1; // Add 1 to include the current day
        _countdownMessage = '$remainingDays ${_getLocalizedText(context, 'days_remaining')}\n${_getLocalizedText(context, 'countdown')}';
      }
    } else {
      _countdownMessage = _getLocalizedText(context, 'select_start_end_dates');
    }
    setState(() {}); // Ensure the UI is updated
  }

  @override
  Widget build(BuildContext context) {
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
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            _getLocalizedText(context, 'countdown'),
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align children to the start
          children: [
            SizedBox(height: 50), // Increase the height to move the circle slightly lower
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha((0.3 * 255).toInt()), // Circular background color
              ),
              child: Center(
                child: Text(
                  '🔙🏠',
                  style: TextStyle(fontSize: 68), // Increase font size
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_startDate != null && _endDate != null)
              if (DateTime.now().isBefore(_startDate!))
                Text(
                  _getLocalizedText(context, 'embarkation_not_started'),
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                )
              else if (DateTime.now().isAfter(_endDate!))
                Text(
                  _getLocalizedText(context, 'embarkation_completed'),
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                )
              else
                Column(
                  children: [
                    Text(
                      _getLocalizedText(context, 'days_remaining'),
                      style: TextStyle(fontSize: 24, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0), // Further reduce spacing
                      child: Text(
                        '${_endDate!.difference(DateTime.now()).inDays + 1}', // Add 1 to include the current day
                        style: TextStyle(fontSize: 68, color: Colors.white, fontWeight: FontWeight.bold), // Increase font size and make bold
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
            else
              Text(
                _countdownMessage,
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            if (_isEditMode || _startDate == null || _endDate == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    color: Colors.white,
                    onPressed: () => _selectDate(context, true),
                    child: Text(_getLocalizedText(context, 'start'), style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 20),
                  CupertinoButton(
                    color: Colors.white,
                    onPressed: () => _selectDate(context, false),
                    child: Text(_getLocalizedText(context, 'end'), style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 20),
                  CupertinoButton(
                    color: Colors.red,
                    onPressed: _resetDates,
                    child: Text('Reset', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            if (_startDate != null && _endDate != null && !_isEditMode)
              CupertinoButton(
                color: Colors.white,
                child: Text(_getLocalizedText(context, 'edit'), style: TextStyle(color: Colors.black)),
                onPressed: () {
                  setState(() {
                    _isEditMode = true;
                  });
                },
              ),
            SizedBox(height: 20),
            if (_startDate != null)
              Text(
                '${_getLocalizedText(context, 'start_date')}: ${DateFormat('dd/MM/yyyy').format(_startDate!)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            if (_endDate != null)
              Text(
                '${_getLocalizedText(context, 'end_date')}: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            if (_startDate != null && _endDate != null)
              _endDate!.difference(_startDate!).inDays < 0
                ? Text(
                    _getLocalizedText(context, 'error_start_after_end'),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '${_getLocalizedText(context, 'total_days')}: ${_endDate!.difference(_startDate!).inDays}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
