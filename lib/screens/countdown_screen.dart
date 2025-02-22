import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _countdownMessage = 'Seleziona le date di inizio e fine imbarco';
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
                  Container(
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
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
                    child: Text('OK', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      _saveDates();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateCountdownMessage() {
    if (_startDate != null && _endDate != null) {
      final now = DateTime.now();
      if (now.isBefore(_startDate!)) {
        _countdownMessage = 'L\'imbarco non è ancora iniziato';
      } else if (now.isAfter(_endDate!)) {
        _countdownMessage = 'L\'imbarco è già terminato';
      } else {
        final remainingDays = _endDate!.difference(now).inDays;
        _countdownMessage = 'Mancano\n$remainingDays\n giorni\nper tornare a casa';
      }
    } else {
      _countdownMessage = 'Seleziona le date di inizio e fine imbarco';
    }
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
            'Countdown',
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
                color: Colors.blue.withOpacity(0.3), // Circular background color
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
              Column(
                children: [
                  Text(
                    'Mancano',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0), // Further reduce spacing
                    child: Text(
                      '${_endDate!.difference(DateTime.now()).inDays}',
                      style: TextStyle(fontSize: 68, color: Colors.white, fontWeight: FontWeight.bold), // Increase font size and make bold
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0), // Further reduce spacing
                    child: Text(
                      'giorni',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'per tornare a casa',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
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
                    child: Text('Inizio', style: TextStyle(color: Colors.black)),
                    onPressed: () => _selectDate(context, true),
                  ),
                  SizedBox(width: 20),
                  CupertinoButton(
                    color: Colors.white,
                    child: Text('Fine', style: TextStyle(color: Colors.black)),
                    onPressed: () => _selectDate(context, false),
                  ),
                ],
              ),
            if (_startDate != null && _endDate != null && !_isEditMode)
              CupertinoButton(
                color: Colors.white,
                child: Text('Modifica', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  setState(() {
                    _isEditMode = true;
                  });
                },
              ),
            SizedBox(height: 20),
            if (_startDate != null)
              Text(
                'Data di inizio: ${DateFormat('dd/MM/yyyy').format(_startDate!)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            if (_endDate != null)
              Text(
                'Data di fine: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            if (_startDate != null && _endDate != null)
              Text(
                'Giorni totali: ${_endDate!.difference(_startDate!).inDays}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
