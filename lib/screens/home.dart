// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:blog_app/screens/article_details.dart';
import 'package:blog_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Article>>? _articlesFuture;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken =
        prefs.getString('auth_token'); // Change to your actual key

    if (authToken != null) {
      final Uri apiUrl =
          Uri.parse('https://inhollandbackend.azurewebsites.net/api/Articles');

      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-authtoken': authToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['Results'];

        final List<Article> newArticles =
            results.map((result) => Article.fromJson(result)).toList();

        setState(() {
          _articlesFuture = Future.value(newArticles);
        });
      } else {
        // Handle error
      }
    } else {
      // Handle missing authToken
      print('Auth token is missing.');
    }
  }

  // Function to like/unlike an article
  Future<void> toggleLikeArticle(int articleId, bool isLiked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken =
        prefs.getString('auth_token'); // Change to your actual key

    if (authToken != null) {
      final Uri apiUrl = Uri.parse(
          'https://inhollandbackend.azurewebsites.net/api/Articles/$articleId/like');

      final response = isLiked
          ? await http.delete(
              apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'x-authtoken': authToken,
              },
            )
          : await http.put(
              apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'x-authtoken': authToken,
              },
            );

      if (response.statusCode == 200) {
        // Article liked/unliked successfully
        final toastMessage = isLiked
            ? 'Article unliked successfully'
            : 'Article liked successfully';
        Fluttertoast.showToast(
          msg: toastMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Handle error
        Fluttertoast.showToast(
          msg: 'Failed to like article. Status code: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // Handle missing authToken
      Fluttertoast.showToast(
        msg: 'Auth token is missing.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HomeScreen()), // Replace the current screen
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Remove the auth token from shared preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');

              // Navigate to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LoginScreen()), // Replace the current screen
              ); // Replace '/login' with your actual login screen route
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildShimmerListView();
          } else if (snapshot.hasError) {
            return _buildShimmerListView();
          } else {
            final articles = snapshot.data!;
            return _buildArticleListView(articles);
          }
        },
      ),
    );
  }

  Widget _buildShimmerListView() {
    return ListView.builder(
      itemCount: 20, // You can adjust the number of shimmer items as needed
      itemBuilder: (context, index) {
        return ListTile(
          title: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          leading: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleListView(List<Article> articles) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Container(
          alignment: Alignment.center,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // Adjust the border color as needed
              width: 1.0, // Adjust the border width as needed
            ),
          ),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsScreen(
                    title: article.title,
                    summary: article.summary,
                    image: article.image,
                    url: article.url,
                  ),
                ),
              );
            },
            horizontalTitleGap: 10,
            titleAlignment: ListTileTitleAlignment.center,
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            leading: Image.network(
              article.image, width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              fit: BoxFit.cover,
            ), // Maintain aspect ratio and cover the space),
            trailing: IconButton(
              icon: Icon(
                article.isLiked ? Icons.favorite : Icons.favorite_border,
                color: article.isLiked ? Colors.red : null,
              ),
              onPressed: () async {
                final bool isLiked = article.isLiked;
                await toggleLikeArticle(article.id, isLiked);
                setState(() {
                  article.isLiked = !isLiked; // Toggle the liked state
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class Article {
  final int id;
  final String title;
  final String summary;
  final String image;
  final String url;
  bool isLiked;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.image,
    required this.url,
    required this.isLiked,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['Id'],
      title: json['Title'],
      summary: json['Summary'],
      image: json['Image'],
      url: json['Url'],
      isLiked: json['IsLiked'],
    );
  }
}
