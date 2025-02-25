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
  XFile? _imageFile;
  String? _pdfPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path;
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
        builder: (context) => FileViewerScreen(filePath: filePath, fileType: fileType),
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
      return '${difference.inDays} giorni';
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
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            widget.course.name,
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
      ),
      body: SingleChildScrollView( // Wrap the Column in SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
            children: [
              SizedBox(height: 50), // Add space above the circle
              Center(
                child: Column(
                  children: [
                    Text(
                      'Il corso scadrà tra:',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8), // Add space between the text and the circle
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _getCircleColor(),
                        shape: BoxShape.circle,
                        border: Border.all(color: _getBorderColor(), width: 3), // Add border
                      ),
                      child: Center(
                        child: Text(
                          _getDaysRemaining(),
                          style: TextStyle(fontSize: 24, color: _getTextColor(), fontWeight: FontWeight.bold), // Use the same text color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (_imageFile != null)
                GestureDetector(
                  onTap: () => _openFile(context, _imageFile!.path, 'image'),
                  child: Image.file(File(_imageFile!.path)),
                ),
              if (_pdfPath != null)
                GestureDetector(
                  onTap: () => _openFile(context, _pdfPath!, 'pdf'),
                  child: SizedBox(
                    height: 400,
                    child: PDFView(
                      filePath: _pdfPath,
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
