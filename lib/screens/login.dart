// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:blog_app/screens/tabs.dart';
import 'package:blog_app/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                labelStyle: TextStyle(
                  color: Colors.blue, // Change label text color
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Change border color
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Use primary color
                  ),
                ),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Colors.blue, // Change label text color
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Change border color
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Use primary color
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.blue,
                ),
                suffixIcon: GestureDetector(
                  onTap: togglePasswordVisibility,
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue,
                  ),
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                // Navigate to the signup screen when the "Sign Up" button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text('Not registered? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'UserName': username,
      'Password': password,
    };

    final Uri apiUrl =
        Uri.parse('https://inhollandbackend.azurewebsites.net/api/Users/login');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Successful login
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String authToken = responseData['AuthToken'];
        print("AuthToken: $authToken");
        // Store the user's auth token using shared_preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', authToken);

        Fluttertoast.showToast(
          msg: "Login successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

// Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const TabScreen()), // Replace the current screen
        );
      } else {
        // Handle other status codes or error responses

        Fluttertoast.showToast(
          msg: 'Login Failed! Check username and password',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      // Handle any network or unexpected errors
      Fluttertoast.showToast(
        msg: "An error occurred. Please check your internet connection.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
