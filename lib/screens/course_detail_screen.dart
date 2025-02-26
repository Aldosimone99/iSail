import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import for File class
import 'package:flutter/cupertino.dart'; // Import for CupertinoActionSheet
import '../models/course.dart';
import 'file_viewer_screen.dart'; // Import for FileViewerScreen

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String? _pdfPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        widget.course.imagePath = pickedFile.path; // Save image path to course
      });
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path;
        widget.course.pdfPath = _pdfPath; // Save PDF path to course
      });
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
                  title: Text('Carica il corso', style: TextStyle(color: Colors.white)), // White text color
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: Text('Seleziona dalla Galleria', style: TextStyle(color: Colors.white)), // White text color
                      onPressed: () {
                        _pickImage();
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: Text('Seleziona da File', style: TextStyle(color: Colors.white)), // White text color
                      onPressed: () {
                        _pickPDF();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    child: Text('Annulla', style: TextStyle(color: Colors.white)), // White text color
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
          onDelete: () {
            setState(() {
              if (fileType == 'image') {
                widget.course.imagePath = null; // Remove image path from course
              } else if (fileType == 'pdf') {
                _pdfPath = null;
                widget.course.pdfPath = null; // Remove PDF path from course
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

  String _getDaysRemaining() {
    final now = DateTime.now();
    final difference = widget.course.deadline.difference(now);
    if (difference.isNegative) {
      return 'Scaduto';
    } else {
      final years = difference.inDays ~/ 365;
      final months = (difference.inDays % 365) ~/ 30;
      final days = (difference.inDays % 365) % 30;
      return '${years > 0 ? '$years anni ' : ''}${months > 0 ? '$months mesi ' : ''}${days > 0 ? '$days giorni' : ''}';
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
                      'Il corso scadrà tra:',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8), // Add space between the text and the circle
                    Container(
                      width: 140, // Increase the width of the circle
                      height: 140, // Increase the height of the circle
                      decoration: BoxDecoration(
                        color: _getCircleColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: _getBorderColor(), width: 3), // Add border
                      ),
                      child: Center(
                        child: Text(
                          _getDaysRemaining(),
                          textAlign: TextAlign.center, // Center the text
                          style: TextStyle(fontSize: 24, color: _getTextColor(), fontWeight: FontWeight.bold), // Use the same text color
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
