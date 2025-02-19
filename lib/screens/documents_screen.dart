import 'package:flutter/material.dart';
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<List<String>> _loadPdfFiles() async {
    // List the PDF files you have added to your project
    return [
      'assets/documents/document1.pdf',
      'assets/documents/document2.pdf',
      'assets/documents/document3.pdf',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documenti'),
      ),
      body: FutureBuilder<List<String>>(
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
                final pdfPath = pdfFiles[index];
                final pdfName = pdfPath.split('/').last;
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
