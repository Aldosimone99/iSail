import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import for File class
import 'package:flutter/cupertino.dart'; // Import for CupertinoActionSheet
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../models/course.dart';
import 'file_viewer_screen.dart'; // Import for FileViewerScreen

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.course.imagePath = prefs.getString('course_${widget.course.id}_imagePath');
      widget.course.pdfPath = prefs.getString('course_${widget.course.id}_pdfPath');
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('course_${widget.course.id}_imagePath', path);
    setState(() {
      widget.course.imagePath = path;
    });
  }

  Future<void> _savePDFPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('course_${widget.course.id}_pdfPath', path);
    setState(() {
      widget.course.pdfPath = path;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _saveImagePath(pickedFile.path); // Save image path to SharedPreferences
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      await _savePDFPath(result.files.single.path!); // Save PDF path to SharedPreferences
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
                        _pickImage();
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: Text(_getLocalizedText(context, 'select_from_files'), style: TextStyle(color: Colors.white)), // White text color
                      onPressed: () {
                        _pickPDF();
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
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              if (fileType == 'image') {
                widget.course.imagePath = null; // Remove image path from course
                prefs.remove('course_${widget.course.id}_imagePath'); // Remove image path from SharedPreferences
              } else if (fileType == 'pdf') {
                widget.course.pdfPath = null; // Remove PDF path from course
                prefs.remove('course_${widget.course.id}_pdfPath'); // Remove PDF path from SharedPreferences
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
              SizedBox(height: 16),
              if (widget.course.imagePath != null)
                GestureDetector(
                  onTap: () => _openFile(context, widget.course.imagePath!, 'image'),
                  child: Image.file(File(widget.course.imagePath!)),
                ),
              SizedBox(height: 16), // Reduce space above the text
              Center(
                child: Column(
                  children: [
                    Text(
                      _getLocalizedText(context, 'course_will_expire_in'),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2), // Add space between the text and the circle
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
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (widget.course.pdfPath != null)
                GestureDetector(
                  onTap: () => _openFile(context, widget.course.pdfPath!, 'pdf'),
                  child: SizedBox(
                    height: 400,
                    child: PDFView(
                      filePath: widget.course.pdfPath,
                    ),
                  ),
                ),
              // Add more details as needed
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPickerOptions(context),
        child: Icon(Icons.add, color: Colors.black), // Black icon color
        backgroundColor: Colors.white, // White background color
        shape: CircleBorder(), // Ensure the button is round
      ),
    );
  }
}
