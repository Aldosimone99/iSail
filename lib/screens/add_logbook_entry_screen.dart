import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui'; // Import for blur effect

class AddLogbookEntryScreen extends StatefulWidget {
  final Function(Map<String, String>) onAddEntry;

  const AddLogbookEntryScreen({super.key, required this.onAddEntry});

  @override
  AddLogbookEntryScreenState createState() => AddLogbookEntryScreenState();
}

class AddLogbookEntryScreenState extends State<AddLogbookEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Color(0xFF1C1C1E),
          child: Column(
            children: [
              Expanded( // Wrap CupertinoDatePicker with Expanded
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      controller.text = newDateTime.toLocal().toString().split(' ')[0];
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text(_getLocalizedText(context, 'ok'), style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'add_logbook_entry': isEnglish ? 'Add Logbook Entry' : 'Aggiungi Registro Imbarchi',
      'title': isEnglish ? 'Title' : 'Titolo',
      'start_date': isEnglish ? 'Start Date (YYYY-MM-DD)' : 'Data di Inizio (YYYY-MM-DD)',
      'end_date': isEnglish ? 'End Date (YYYY-MM-DD)' : 'Data di Fine (YYYY-MM-DD)',
      'save': isEnglish ? 'Save' : 'Salva',
      'ok': isEnglish ? 'OK' : 'OK',
      'please_enter': isEnglish ? 'Please enter' : 'Per favore inserisci',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sfondo nero OLED
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Color(0xFF1C1C1E).withAlpha(128), // Replace withOpacity with withAlpha (128 is approximately 50% opacity)
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getLocalizedText(context, 'add_logbook_entry'),
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea( // Wrap SingleChildScrollView with SafeArea
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            clipBehavior: Clip.none, // Ignore overflow
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  _buildTextField(_titleController, _getLocalizedText(context, 'title'), context: context),
                  SizedBox(height: 20),
                  _buildTextField(_startDateController, _getLocalizedText(context, 'start_date'),
                      isDateField: true, context: context),
                  SizedBox(height: 20),
                  _buildTextField(_endDateController, _getLocalizedText(context, 'end_date'),
                      isDateField: true, context: context),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final entry = {
                          'title': _titleController.text,
                          'startDate': _startDateController.text,
                          'endDate': _endDateController.text,
                        };
                        widget.onAddEntry(entry);
                        Navigator.pop(context, entry);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(_getLocalizedText(context, 'save')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isDateField = false, required BuildContext context}) {
    return TextFormField(
      controller: controller,
      readOnly: isDateField,
      onTap: isDateField ? () => _selectDate(context, controller) : null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Color(0xFF2C2C2E),
        suffixIcon: isDateField
            ? Icon(Icons.calendar_today, color: Colors.white)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${_getLocalizedText(context, 'please_enter')} $hintText';
        }
        return null;
      },
    );
  }
}
