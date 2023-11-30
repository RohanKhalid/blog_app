// ignore_for_file: library_private_types_in_public_api

import 'package:blog_app/screens/login.dart';
import 'package:blog_app/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool isAuthenticated =
      false; // Initially assume the user is not authenticated

  @override
  void initState() {
    super.initState();
    checkAuthenticationStatus();
  }

  Future<void> checkAuthenticationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken != null) {
      // Check if the auth token is valid by making a request to your server
      final bool isValid = await validateAuthToken(authToken);

      if (isValid) {
        // If the token is valid, set isAuthenticated to true
        setState(() {
          isAuthenticated = true;
        });
      }
    }
  }

  Future<bool> validateAuthToken(String authToken) async {
    // Implement your logic to validate the auth token here.
    // You may need to make a request to your server to verify it.
    // If the token is valid, return true; otherwise, return false.
    return true; // Placeholder logic, replace with actual validation.
  }

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated) {
      // If the user is authenticated, navigate to the main content of the app.
      return const TabScreen();
    } else {
      // If the user is not authenticated, navigate to the login screen.
      return const LoginScreen();
    }
  }
}
