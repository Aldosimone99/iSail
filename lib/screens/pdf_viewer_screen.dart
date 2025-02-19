import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for asset loading
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import flutter_pdfview
import 'dart:io'; // Import dart:io for file operations
import 'package:path_provider/path_provider.dart'; // Import path_provider for temporary directory

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;

  const PdfViewerScreen({super.key, required this.assetPath, required this.title});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _loadPdfFromAssets();
  }

  Future<void> _loadPdfFromAssets() async {
    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final file = File('${(await getTemporaryDirectory()).path}/temp.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          if (_errorMessage.isEmpty && _pdfPath != null)
            PDFView(
              filePath: _pdfPath!,
              onRender: (_pages) {
                setState(() {
                  _isLoading = false;
                });
              },
              onError: (error) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = error.toString();
                });
              },
            ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Center(child: Text('Error: $_errorMessage')),
        ],
      ),
    );
  }
}
