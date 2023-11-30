// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:blog_app/screens/article_details.dart';
import 'package:blog_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<Article>>? _favoriteArticlesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoriteArticles();
  }

  Future<void> _loadFavoriteArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken != null) {
      final Uri apiUrl = Uri.parse(
          'https://inhollandbackend.azurewebsites.net/api/Articles/liked');

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
          _favoriteArticlesFuture = Future.value(newArticles);
        });
      } else {
        // Handle error
        print(
            'Failed to load favorite articles. Status code: ${response.statusCode}');
      }
    } else {
      // Handle missing authToken
      print('Auth token is missing.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const FavoritesScreen()), // Replace the current screen
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
        future: _favoriteArticlesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildShimmerListView();
          } else if (snapshot.hasError) {
            return _buildShimmerListView();
          } else {
            final favoriteArticles = snapshot.data!;
            return _buildArticleListView(favoriteArticles);
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
              article.image,
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              fit: BoxFit.cover,
            ), // Maintain aspect ratio and cover the space),
            trailing: IconButton(
              icon: Icon(
                article.isLiked ? Icons.favorite : Icons.favorite_border,
                color: article.isLiked ? Colors.red : null,
              ), // Always show favorite icon in red
              onPressed: () {
                // Implement logic to unlike the article
                _unlikeArticle(article.id);
                setState(() {
                  article.isLiked = !article.isLiked;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _unlikeArticle(int articleId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken != null) {
      final Uri apiUrl = Uri.parse(
          'https://inhollandbackend.azurewebsites.net/api/Articles/$articleId/like');

      final response = await http.delete(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-authtoken': authToken,
        },
      );

      if (response.statusCode == 200) {
        // Article unliked successfully
        Fluttertoast.showToast(
            msg: 'Article Unliked Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      } else {
        // Handle error
        Fluttertoast.showToast(
          msg: 'Failed to unlike article. Status code: ${response.statusCode}',
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
