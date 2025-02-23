import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'add_logbook_entry_screen.dart'; // Import the new screen
import 'package:shared_preferences/shared_preferences.dart'; // Import for persistent storage
import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:flutter/cupertino.dart'; // Import for Cupertino widgets

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  LogbookScreenState createState() => LogbookScreenState();
}

class LogbookScreenState extends State<LogbookScreen> with SingleTickerProviderStateMixin {
  List<Map<String, String>> _logbookEntries = [];
  bool _isDeleteMode = false;
  String _sortCriteria = 'title';
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _loadLogbookEntries();
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

  Future<void> _loadLogbookEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList('logbookEntries') ?? [];
    setState(() {
      _logbookEntries = entries.map((entry) => Map<String, String>.from(json.decode(entry))).toList();
    });
  }

  Future<void> _saveLogbookEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _logbookEntries.map((entry) => json.encode(entry)).toList();
    await prefs.setStringList('logbookEntries', entries);
  }

  void _addLogbookEntry(Map<String, String> entry) {
    if (!_logbookEntries.contains(entry)) {
      setState(() {
        _logbookEntries.add(entry);
      });
      _saveLogbookEntries();
    }
  }

  void _deleteLogbookEntry(int index) {
    setState(() {
      _logbookEntries.removeAt(index);
      _saveLogbookEntries();
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Conferma Eliminazione'),
          content: Text('Sei sicuro di voler eliminare questo imbarco?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annulla'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                _deleteLogbookEntry(index);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true,
              child: Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  void _sortLogbookEntries() {
    setState(() {
      if (_sortCriteria == 'title') {
        _logbookEntries.sort((a, b) => a['title']!.compareTo(b['title']!));
      } else if (_sortCriteria == 'startDate_asc') {
        _logbookEntries.sort((a, b) => a['startDate']!.compareTo(b['startDate']!));
      } else if (_sortCriteria == 'startDate_desc') {
        _logbookEntries.sort((a, b) => b['startDate']!.compareTo(a['startDate']!));
      }
    });
  }

  void _showSortOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text('Ordina per titolo'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'title';
                _sortLogbookEntries();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Ordina per data di inizio (crescente)'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'startDate_asc';
                _sortLogbookEntries();
              });
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Ordina per data di inizio (decrescente)'),
            onPressed: () {
              setState(() {
                _sortCriteria = 'startDate_desc';
                _sortLogbookEntries();
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

  void _showMenuOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: Text('Ordina'),
            onPressed: () {
              Navigator.pop(context);
              _showSortOptions(context);
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

  String _calculateDuration(String startDate, String endDate) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      months -= 1;
      final previousMonth = DateTime(end.year, end.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return '${years * 12 + months} mesi, $days giorni';
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
            'Registro Imbarchi',
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[300]),
            onPressed: () => _showMenuOptions(context),
          ),
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
        child: _logbookEntries.isEmpty
            ? Center(
                child: Text(
                  'Nessun imbarco presente',
                  style: TextStyle(color: Colors.grey[300], fontSize: 24, fontWeight: FontWeight.bold), // Match font size and style
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two boxes per row
                  crossAxisSpacing: 10.0, // Increase horizontal spacing between cards
                  mainAxisSpacing: 20.0, // Increase vertical spacing between cards
                  childAspectRatio: 1.2, // Adjust the aspect ratio to match course boxes
                ),
                padding: EdgeInsets.all(10),
                itemCount: _logbookEntries.length,
                itemBuilder: (context, index) {
                  final entry = _logbookEntries[index];
                  final duration = _calculateDuration(entry['startDate']!, entry['endDate']!);
                  return ShakeTransition(
                    controller: _controller,
                    enabled: _isDeleteMode,
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add some horizontal margins
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Light gray background color
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[600]!, width: 4), // Increase border thickness
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Darker shadow color
                                blurRadius: 6, // Increase blur radius for a more pronounced shadow
                                offset: Offset(4, 4), // Offset the shadow to the bottom right
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0), // Slightly increase padding
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                              children: [
                                Text(
                                  entry['title']!,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800], // Set text color to dark gray
                                  ),
                                  textAlign: TextAlign.center, // Center the text horizontally
                                  overflow: TextOverflow.visible, // Ensure the text is fully readable
                                ),
                                SizedBox(height: 8), // Add some space between title and subtitle
                                Text(
                                  'Da: ${entry['startDate']} A: ${entry['endDate']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700], // Set text color to gray
                                  ),
                                  textAlign: TextAlign.center, // Center the text horizontally
                                  maxLines: 3, // Limit to a maximum of 3 lines
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if text exceeds 3 lines
                                ),
                                SizedBox(height: 8), // Add some space between subtitle and duration
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Slightly increase padding
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600]!.withAlpha(50), // Light gray background color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    duration,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[800], // Set text color to dark gray
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      color: Colors.black.withAlpha((0.2 * 255).toInt()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLogbookEntryScreen(onAddEntry: _addLogbookEntry)),
          );
          if (result != null) {
            _addLogbookEntry(result);
          }
        }, // Set icon color to black
        backgroundColor: Colors.white, // Set button background color to white
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.black), // Ensure the button is round
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
