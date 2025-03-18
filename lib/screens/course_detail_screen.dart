import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart'; // Import for CupertinoActionSheet
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'dart:io'; // Import for File operations
import '../models/course.dart';
import 'file_viewer_screen.dart'; // Import for FileViewerScreen

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  CourseDetailScreenState createState() => CourseDetailScreenState();
}

class CourseDetailScreenState extends State<CourseDetailScreen> {

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/course_${widget.course.id}_imagePath');
    final pdfPath = File('${directory.path}/course_${widget.course.id}_pdfPath');
    setState(() {
      widget.course.imagePath = imagePath.existsSync() ? imagePath.path : null;
      widget.course.pdfPath = pdfPath.existsSync() ? pdfPath.path : null;
    });
  }

  Future<void> _saveFilePath(String path, FileType type) async {
    final directory = await getApplicationDocumentsDirectory();
    final key = type == FileType.image ? 'imagePath' : 'pdfPath';
    final file = File('${directory.path}/course_${widget.course.id}_$key');
    
    // Delete the previous file if it exists
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Copy the selected file to the app's directory
    final originalFile = File(path);
    await originalFile.copy(file.path);
    
    setState(() {
      if (type == FileType.image) {
        widget.course.imagePath = file.path;
      } else {
        widget.course.pdfPath = file.path;
      }
    });
  }

  Future<void> _pickFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(type: type);
    if (result != null) {
      await _saveFilePath(result.files.single.path!, type);
    }
  }

  void _showPickerOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black54, // Semi-transparent gray background
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: CupertinoActionSheet(
                  title: Text(_getLocalizedText(context, 'upload_course'), style: TextStyle(color: Colors.white)), // White text color
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: Text(_getLocalizedText(context, 'select_from_gallery'), style: TextStyle(color: Colors.white)), // White text color
                      onPressed: () {
                        _pickFile(FileType.image);
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: Text(_getLocalizedText(context, 'select_from_files'), style: TextStyle(color: Colors.white)), // White text color
                      onPressed: () {
                        _pickFile(FileType.any);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    child: Text(_getLocalizedText(context, 'cancel'), style: TextStyle(color: Colors.white)), // White text color
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openFile(BuildContext context, String filePath, String fileType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(
          filePath: filePath,
          fileType: fileType,
          onDelete: () async {
            final directory = await getApplicationDocumentsDirectory();
            final key = fileType == 'image' ? 'imagePath' : 'pdfPath';
            final file = File('${directory.path}/course_${widget.course.id}_$key');
            if (file.existsSync()) {
              file.deleteSync();
            }
            setState(() {
              if (fileType == 'image') {
                widget.course.imagePath = null;
              } else if (fileType == 'pdf') {
                widget.course.pdfPath = null;
              }
            });
            Navigator.of(context).pop(); // Close the FileViewerScreen
          },
        ),
      ),
    );
  }

  Color _getCircleColor() {
    final now = DateTime.now();
    if (widget.course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Color(0xFFFEE9E8); // Light red background for due within 6 months
    } else if (widget.course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFFDF5D5); // Light yellow background for due between 6 months and a year
    } else {
      return Color(0xFFE0F7F1); // Light green background for due after a year
    }
  }

  Color _getBorderColor() {
    final now = DateTime.now();
    if (widget.course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Colors.red; // Red for due within 6 months
    } else if (widget.course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color(0xFFF4C34D); // Yellow for due between 6 months and a year
    } else {
      return Colors.green; // Green for due after a year
    }
  }

  Color _getTextColor() {
    final now = DateTime.now();
    if (widget.course.deadline.isBefore(now.add(Duration(days: 180)))) {
      return Colors.red; // Red text color for red boxes
    } else if (widget.course.deadline.isBefore(now.add(Duration(days: 365)))) {
      return Color.fromARGB(255, 171, 130, 10); // Dark golden color for yellow boxes
    } else {
      return Colors.green; // Green text color for green boxes
    }
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'course_will_expire_in': isEnglish ? 'The course will expire in:' : 'Il corso scadrà tra:',
      'expired': isEnglish ? 'Expired' : 'Scaduto',
      'upload_course': isEnglish ? 'Upload Course' : 'Carica il corso',
      'select_from_gallery': isEnglish ? 'Select from Gallery' : 'Seleziona dalla Galleria',
      'select_from_files': isEnglish ? 'Select from Files' : 'Seleziona da File',
      'cancel': isEnglish ? 'Cancel' : 'Annulla',
      'year': isEnglish ? 'year' : 'anno',
      'years': isEnglish ? 'years' : 'anni',
      'month': isEnglish ? 'month' : 'mese',
      'months': isEnglish ? 'months' : 'mesi',
      'day': isEnglish ? 'day' : 'giorno',
      'days': isEnglish ? 'days' : 'giorni',
    };
    return translations[key] ?? key;
  }

  String _getLocalizedButtonText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'view_image': isEnglish ? 'View Image' : 'Visualizza Immagine',
      'view_pdf': isEnglish ? 'View PDF' : 'Visualizza PDF',
    };
    return translations[key] ?? key;
  }

  List<String> _getDaysRemaining(BuildContext context) {
    final now = DateTime.now();
    final difference = widget.course.deadline.difference(now);
    if (difference.isNegative) {
      return [_getLocalizedText(context, 'expired')];
    } else {
      final years = difference.inDays ~/ 365;
      final months = (difference.inDays % 365) ~/ 30;
      final days = (difference.inDays % 365) % 30;
      final yearsText = years > 0 ? '$years ${years == 1 ? _getLocalizedText(context, 'year') : _getLocalizedText(context, 'years')}' : '';
      final monthsText = months > 0 ? '$months ${months == 1 ? _getLocalizedText(context, 'month') : _getLocalizedText(context, 'months')}' : '';
      final daysText = days > 0 ? '$days ${days == 1 ? _getLocalizedText(context, 'day') : _getLocalizedText(context, 'days')}' : '';
      return [yearsText, monthsText, daysText].where((text) => text.isNotEmpty).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align content to the left
          crossAxisAlignment: CrossAxisAlignment.center, // Center align vertically
          children: [
            IconButton(
              icon: Icon(CupertinoIcons.back, color: Colors.grey[300], size: 30), // Use the back arrow without the line and increase size
              onPressed: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: 1), // Reduce space between the icon and the title
            Expanded(
              child: Text(
                widget.course.name,
                style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
                overflow: TextOverflow.ellipsis, // Truncate long text with ellipsis
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView( // Wrap the Column in SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
            children: [
              SizedBox(height: 32), // Increase the top padding
              Center(
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText(context, 'course_will_expire_in'),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16), // Increase space between the text and the circle
                    Container(
                      width: 150, // Increase the width of the circle
                      height: 150, // Increase the height of the circle
                      decoration: BoxDecoration(
                        color: _getCircleColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: _getBorderColor(), width: 3), // Add border
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _getDaysRemaining(context).map((text) => Text(
                            text,
                            textAlign: TextAlign.center, // Center the text
                            style: TextStyle(fontSize: 24, color: _getTextColor(), fontWeight: FontWeight.bold), // Use the same text color
                          )).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 32), // Increase space between the circle and the buttons
                    if (widget.course.imagePath != null && widget.course.pdfPath != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                            ),
                            onPressed: () => _openFile(context, widget.course.imagePath!, 'image'),
                            child: Text(_getLocalizedButtonText(context, 'view_image')),
                          ),
                          SizedBox(width: 16), // Space between buttons
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                            ),
                            onPressed: () => _openFile(context, widget.course.pdfPath!, 'pdf'),
                            child: Text(_getLocalizedButtonText(context, 'view_pdf')),
                          ),
                        ],
                      )
                    else if (widget.course.imagePath != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                        ),
                        onPressed: () => _openFile(context, widget.course.imagePath!, 'image'),
                        child: Text(_getLocalizedButtonText(context, 'view_image')),
                      )
                    else if (widget.course.pdfPath != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                        ),
                        onPressed: () => _openFile(context, widget.course.pdfPath!, 'pdf'),
                        child: Text(_getLocalizedButtonText(context, 'view_pdf')),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 32), // Increase bottom padding
              // Add more details as needed
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPickerOptions(context), // Black icon color
        backgroundColor: Colors.white, // White background color
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.black), // Ensure the button is round
      ),
    );
  }
}
