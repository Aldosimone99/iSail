import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart'; // Import for Share
import 'dart:io';

class FileViewerScreen extends StatelessWidget {
  final String filePath;
  final String fileType;
  final Function onDelete;

  const FileViewerScreen({super.key, required this.filePath, required this.fileType, required this.onDelete});

  void _shareFile(BuildContext context) {
    Share.shareFiles([filePath]);
  }

  void _deleteFile(BuildContext context) {
    onDelete();
    Navigator.of(context).pop();
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
            Text(
              'Visualizza File',
              style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: fileType == 'image'
                ? Image.file(File(filePath))
                : PDFView(
                    filePath: filePath,
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Color(0xFF1C1C1E), // Dark background color
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Icon(CupertinoIcons.share, color: Colors.white),
                      onPressed: () => _shareFile(context),
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.trash, color: Colors.white), // Replace 'x' icon with trash icon
                      onPressed: () => _deleteFile(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
