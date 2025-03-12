import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui'; // Import for blur effect
import 'package:html/parser.dart' as parser; // Import for HTML parsing
import 'package:html/dom.dart' as dom; // Import for HTML DOM manipulation
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:url_launcher/url_launcher_string.dart'; // Import for URL launcher with string support

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
    print('Locale: $locale, Language: $_language'); // Debug print
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final url = _language == 'it'
          ? 'https://news.google.com/rss/search?q=navi+crociera&hl=it&gl=IT&ceid=IT:it'
          : 'https://news.google.com/rss/search?q=cruise+ships&hl=en&gl=US&ceid=US:en';
      print('Fetching news from: $url'); // Debug print
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final items = document.getElementsByTagName('item');
        final DateFormat dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
        final List<dynamic> articles = await Future.wait(items.map((dom.Element element) async {
          final title = element.getElementsByTagName('title').first.text;
          final linkElement = element.getElementsByTagName('link').first;
          final link = linkElement.text.trim();
          final descriptionElement = element.getElementsByTagName('description').first;
          final description = descriptionElement.text;
          final linkFromDescription = RegExp(r'href="(.*?)"').firstMatch(description)?.group(1) ?? link;
          final pubDate = element.getElementsByTagName('pubDate').first.text;
          final imageUrl = await _fetchMainImage(linkFromDescription);
          return {
            'title': title,
            'url': linkFromDescription,
            'publishedAt': dateFormat.parse(pubDate).toIso8601String(),
            'urlToImage': imageUrl,
          };
        }).toList());
        articles.sort((a, b) => DateTime.parse(b['publishedAt']).compareTo(DateTime.parse(a['publishedAt']))); // Sort by date
        setState(() {
          _news = articles;
        });
      } else {
        // Handle error
        print('Failed to load news: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  Future<String> _fetchMainImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'Mozilla/5.0'});
      if (response.isRedirect) {
        final redirectedUrl = response.headers['location'];
        if (redirectedUrl != null) {
          return await _fetchMainImage(redirectedUrl);
        }
      }
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final metaTags = document.getElementsByTagName('meta');
        for (var meta in metaTags) {
          if (meta.attributes['property'] == 'og:image' || meta.attributes['name'] == 'twitter:image') {
            return meta.attributes['content'] ?? '';
          }
        }
        // Fallback to finding the first image in the article
        final images = document.getElementsByTagName('img');
        if (images.isNotEmpty) {
          return images.first.attributes['src'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching main image: $e');
    }
    return '';
  }

  Future<void> _openNews(String url) async {
    if (url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        print('Could not launch $url');
      }
    } else {
      print('Invalid URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'it' ? 'Notizie' : 'News';

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
            title,
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
                final publishedAt = DateFormat.yMMMd().format(DateTime.parse(newsItem['publishedAt']));

                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
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
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              'No image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                  title: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increase font size
                    ),
                  ),
                  subtitle: Text(
                    publishedAt,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => _openNews(url), // Open the news URL when tapped
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
