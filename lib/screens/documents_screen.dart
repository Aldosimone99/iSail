import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<List<Map<String, String>>> _loadPdfFiles() async {
    // List the PDF files you have added to your project with custom names
    return [
      {'path': 'assets/documents/document1.pdf', 'name': 'Colreg'},
      {'path': 'assets/documents/document2.pdf', 'name': 'Document 2'},
      {'path': 'assets/documents/document3.pdf', 'name': 'Document 3'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documenti'),
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
            return ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                final pdfFile = pdfFiles[index];
                final pdfPath = pdfFile['path']!;
                final pdfName = pdfFile['name']!;
                return ListTile(
                  title: Text(pdfName),
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
                );
              },
            );
          }
        },
      ),
    );
  }
}
