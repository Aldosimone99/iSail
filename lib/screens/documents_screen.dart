import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect
import 'pdf_viewer_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  DocumentsScreenState createState() => DocumentsScreenState();
}

class DocumentsScreenState extends State<DocumentsScreen> {
  String _searchQuery = '';

  Future<List<Map<String, String>>> _loadPdfFiles() async {
    // List the PDF files you have added to your project with custom names
    List<Map<String, String>> pdfFiles = [
      {'path': 'assets/documents/document1.pdf', 'title': 'COLREG 🇮🇹', 'subtitle': 'Regolamento internazionale per prevenire gli abbordi in mare'},
      {'path': 'assets/documents/document2.pdf', 'title': 'COLREG 🇬🇧', 'subtitle': 'Collision Regulations'},
      {'path': 'assets/documents/document3.pdf', 'title': 'MLC 🇮🇹', 'subtitle': 'Convenzione sul lavoro marittimo'},
      {'path': 'assets/documents/document4.pdf', 'title': 'MLC 🇬🇧', 'subtitle': 'Maritime Labour Convention'},
      {'path': 'assets/documents/document5.pdf', 'title': 'MARPOL 🇮🇹', 'subtitle': 'Convenzione internazionale per la prevenzione dell’inquinamento causato da navi '},
      {'path': 'assets/documents/document6.pdf', 'title': 'MARPOL 🇬🇧', 'subtitle': 'Marine Pollution Convention'},
      {'path': 'assets/documents/document7.pdf', 'title': 'SOLAS 🇮🇹', 'subtitle': 'Convenzione internazionale per la salvaguardia della vita umana in mare'},
      {'path': 'assets/documents/document8.pdf', 'title': 'SOLAS 🇬🇧', 'subtitle': 'Safety of Life at Sea'},
      {'path': 'assets/documents/document9.pdf', 'title': 'STCW 🇮🇹', 'subtitle': 'Convenzione internazionale sugli standard di formazione, certificazione e tenuta della guardia per i marittimi'},
      {'path': 'assets/documents/document10.pdf', 'title': 'STCW 🇬🇧', 'subtitle': 'Standards of Training, Certification and Watchkeeping for Seafarers'},
      {'path': 'assets/documents/document11.pdf', 'title': 'ISM Code 🇮🇹', 'subtitle': 'Codice internazionale di gestione della sicurezza'},
      {'path': 'assets/documents/document12.pdf', 'title': 'ISM Code 🇬🇧', 'subtitle': 'International Safety Management Code'},
      {'path': 'assets/documents/document13.pdf', 'title': 'ISPS Code 🇮🇹', 'subtitle': 'Codice internazionale per la sicurezza delle navi e delle strutture portuali'},
      {'path': 'assets/documents/document14.pdf', 'title': 'ISPS Code 🇬🇧', 'subtitle': 'International Ship and Port Facility Security Code'},
      {'path': 'assets/documents/document15.pdf', 'title': 'Load Line Convention 🇮🇹', 'subtitle': 'Convenzione sul bordo libero'},
      {'path': 'assets/documents/document16.pdf', 'title': 'Load Line Convention 🇬🇧', 'subtitle': 'Load Lines Convention'},
      {'path': 'assets/documents/document17.pdf', 'title': 'IMDG Code 🇮🇹', 'subtitle': 'Codice marittimo internazionale delle merci pericolose'},
      {'path': 'assets/documents/document18.pdf', 'title': 'IMDG Code 🇬🇧', 'subtitle': 'International Maritime Dangerous Goods Code'},
    ];
    pdfFiles.sort((a, b) => a['title']!.compareTo(b['title']!));
    return pdfFiles;
  }

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';
    final translations = {
      'conventions': isEnglish ? 'Conventions' : 'Convenzioni',
      'search': isEnglish ? 'Search...' : 'Cerca...',
      'loading_error': isEnglish ? 'Error loading documents.' : 'Errore nel caricamento dei documenti.',
      'no_documents': isEnglish ? 'No documents available.' : 'Nessun documento disponibile.',
      'open_pdf': isEnglish ? 'Open PDF' : 'Apri PDF',
    };
    return translations[key] ?? key;
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
              color: Color(0xFF1C1C1E).withAlpha((0.5 * 255).toInt()), // Set semi-transparent background color
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft, // Align the title text to the left
          child: Text(
            _getLocalizedText(context, 'conventions'),
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
            return Center(child: Text(_getLocalizedText(context, 'loading_error')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(_getLocalizedText(context, 'no_documents')));
          } else {
            var pdfFiles = snapshot.data!;
            pdfFiles = pdfFiles.where((pdfFile) {
              return pdfFile['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     pdfFile['subtitle']!.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _getLocalizedText(context, 'search'),
                            filled: true,
                            fillColor: Color(0xFF2C2C2E), // Light gray color
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Make the borders more rounded
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
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
                      final pdfName = pdfFile['title']!; // Change 'name' to 'title'
                      final pdfSubtitle = pdfFile['subtitle']!; // Add subtitle
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
                                SizedBox(height: 8), // Add some space between title and subtitle
                                Text(
                                  pdfSubtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700], // Set text color to gray
                                  ),
                                  textAlign: TextAlign.center, // Center the text horizontally
                                  maxLines: 3, // Limit to a maximum of 3 lines
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if text exceeds 3 lines
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
                                      _getLocalizedText(context, 'open_pdf'),
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
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
