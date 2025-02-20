import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<List<Map<String, String>>> _loadPdfFiles() async {
    // List the PDF files you have added to your project with custom names
    return [
      {'path': 'assets/documents/document1.pdf', 'name': 'COLREG (International Regulations for Preventing Collisions at Sea) - ITA'},
      {'path': 'assets/documents/document2.pdf', 'name': 'COLREG (International Regulations for Preventing Collisions at Sea) - ENG'},
      {'path': 'assets/documents/document3.pdf', 'name': 'MLC (Maritime Labour Convention) - ITA'},
      {'path': 'assets/documents/document4.pdf', 'name': 'MLC (Maritime Labour Convention) - ENG'},
      {'path': 'assets/documents/document5.pdf', 'name': 'MARPOL Convention - ITA'},
      {'path': 'assets/documents/document6.pdf', 'name': 'MARPOL Convention - ENG'},
      {'path': 'assets/documents/document7.pdf', 'name': 'SOLAS Convention - ITA'},
      {'path': 'assets/documents/document8.pdf', 'name': 'SOLAS Convention - ENG'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convenzioni'),
        backgroundColor: const Color.fromARGB(0, 255, 255, 255), // Make the AppBar transparent
        elevation: 0, // Remove the AppBar shadow
      ),
      body: Stack(
        children: [
          // Light blue blur background
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFB3E5FC).withAlpha(128), // Light blue color with alpha
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Color(0xFFB3E5FC).withAlpha(128), // Light blue color with alpha
              ),
            ),
          ),
          FutureBuilder<List<Map<String, String>>>(
            future: _loadPdfFiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Errore nel caricamento dei documenti.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Nessun documento disponibile.'));
              } else {
                final pdfFiles = snapshot.data!;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two boxes per row
                    childAspectRatio: 3 / 2, // Adjust the aspect ratio as needed
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  padding: EdgeInsets.all(10),
                  itemCount: pdfFiles.length,
                  itemBuilder: (context, index) {
                    final pdfFile = pdfFiles[index];
                    final pdfPath = pdfFile['path']!;
                    final pdfName = pdfFile['name']!;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreen(
                              assetPath: pdfPath,
                              title: pdfName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(129, 255, 235, 59), // Yellow background color
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.yellow, width: 2), // Yellow border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Darker shadow color
                              blurRadius: 6, // Increase blur radius for a more pronounced shadow
                              offset: Offset(4, 4), // Offset the shadow to the bottom right
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            pdfName,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black), // Set text color to black
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
