import 'package:blog_app/screens/login.dart';
import 'package:blog_app/screens/signup.dart';
import 'package:flutter/material.dart';

class LoginSignupBottomSheet extends StatelessWidget {
  const LoginSignupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Navigate to the login screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Signup'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Navigate to the signup screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
