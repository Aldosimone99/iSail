import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui'; // Import for blur effect

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _news = [];
  String _language = 'en';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    _language = locale == 'it' ? 'it' : 'en';
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('https://newsapi.org/v2/everything?q=maritime&language=$_language&apiKey=a176c42ccc144d9eaef246b83cd6c68b')); // Replace with your API key
      if (response.statusCode == 200) {
        setState(() {
          _news = json.decode(response.body)['articles'];
        });
      } else {
        // Gestisci l'errore
        print('Failed to load news: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
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
            'News',
            style: TextStyle(fontSize: 24, color: Colors.grey[300], fontWeight: FontWeight.bold), // Increase the font size, set color to light gray, and make bold
          ),
        ),
      ),
      body: _news.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _news.length,
              itemBuilder: (context, index) {
                final newsItem = _news[index];
                final title = newsItem['title'] ?? 'No title';
                final description = newsItem['description'] ?? 'No description';
                return ListTile(
                  title: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    description,
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    // Azione al tocco della notizia
                  },
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
