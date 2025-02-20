import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<List<Map<String, String>>> _loadPdfFiles() async {
    // List the PDF files you have added to your project with custom names
    return [
      {'path': 'assets/documents/document1.pdf', 'name': 'COLREG - ITA'},
      {'path': 'assets/documents/document2.pdf', 'name': 'COLREG - ENG'},
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
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.transparent, // Set AppBar background color to transparent
        elevation: 0, // Remove AppBar shadow
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
            child: Container(
              color: Color(0xFF1C1C1E).withOpacity(0.5), // Set semi-transparent background color
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            'Convenzioni',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Increase the font size, set color to white, and make bold
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
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
                crossAxisSpacing: 10.0, // Increase horizontal spacing between cards
                mainAxisSpacing: 20.0, // Increase vertical spacing between cards
                childAspectRatio: 1.2, // Adjust the aspect ratio to match course boxes
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
                            pdfName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800], // Set text color to dark gray
                            ),
                            textAlign: TextAlign.center, // Center the text horizontally
                            overflow: TextOverflow.visible, // Ensure the text is fully readable
                          ),
                          Spacer(), // Push the text to the bottom
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Slightly increase padding
                              decoration: BoxDecoration(
                                color: Colors.grey[600]!.withAlpha(50), // Light gray background color
                                borderRadius: BorderRadius.circular(20),
                              ),
                              constraints: BoxConstraints(minWidth: 100), // Allow the pill to expand freely
                              child: Text(
                                'Apri PDF',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800], // Set text color to dark gray
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
