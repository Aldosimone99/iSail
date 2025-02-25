import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart'; // Import for Share
import 'dart:io';

class FileViewerScreen extends StatelessWidget {
  final String filePath;
  final String fileType;

  const FileViewerScreen({super.key, required this.filePath, required this.fileType});

  void _shareFile(BuildContext context) {
    Share.shareFiles([filePath]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizza File'),
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
                      child: Icon(CupertinoIcons.xmark, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
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
