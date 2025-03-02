import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui'; // Import for blur effect
import 'package:url_launcher/url_launcher.dart'; // Import for URL launcher

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
      final response = await http.get(Uri.parse('https://newsapi.org/v2/everything?q=cruise+ships&language=$_language&apiKey=a176c42ccc144d9eaef246b83cd6c68b')); // Replace with your API key
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

  Future<void> _openNews(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
          : ListView.separated(
              itemCount: _news.length,
              separatorBuilder: (context, index) => Divider(color: Colors.grey[700]), // Add divider between news items
              itemBuilder: (context, index) {
                final newsItem = _news[index];
                final title = newsItem['title'] ?? 'No title';
                final imageUrl = newsItem['urlToImage'] ?? '';
                final url = newsItem['url'] ?? '';

                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      'No image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  'No image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                      SizedBox(height: 5),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _openNews(url), // Open the news URL when tapped
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
