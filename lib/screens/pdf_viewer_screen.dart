import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for asset loading
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Import syncfusion_flutter_pdfviewer
import 'dart:io'; // Import dart:io for file operations
import 'package:path_provider/path_provider.dart'; // Import path_provider for temporary directory
import 'dart:ui'; // Import dart:ui for ImageFilter

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;

  const PdfViewerScreen({super.key, required this.assetPath, required this.title});

  @override
  PdfViewerScreenState createState() => PdfViewerScreenState();
}

class PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  String? _pdfPath;
  late PdfViewerController _pdfViewerController;
  late PdfTextSearchResult _searchResult;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _searchResult = PdfTextSearchResult();
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

  void _searchText() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      _searchResult = await _pdfViewerController.searchText(query);
      if (_searchResult.totalInstanceCount > 0) {
        _searchResult.nextInstance(); // Navigate to the first result immediately
      }
      setState(() {}); // Update UI to show the number of results
    }
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'search_in_pdf': isEnglish ? 'Search in PDF...' : 'Cerca nel PDF...',
    };
    return translations[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Color(0xFF1C1C1E).withAlpha((0.5 * 255).toInt()), // Set semi-transparent background color
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_searchResult.hasResult) {
                _searchResult.previousInstance();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              if (_searchResult.hasResult) {
                _searchResult.nextInstance();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _getLocalizedText(context, 'search_in_pdf'),
                      filled: true,
                      fillColor: Color(0xFF2C2C2E), // Light gray color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchText,
                ),
              ],
            ),
          ),
          // PDF Viewer
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isEmpty && _pdfPath != null
                    ? SfPdfViewer.file(
                        File(_pdfPath!),
                        controller: _pdfViewerController,
                        onDocumentLoaded: (details) {
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        onDocumentLoadFailed: (details) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = 'Error loading PDF: ${details.error}';
                          });
                        },
                      )
                    : Center(child: Text('Error: $_errorMessage')),
          ),
        ],
      ),
    );
  }
}
