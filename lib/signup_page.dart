import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';

// Stateful widget for the signup page where users can register an account
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers to manage input values for username, email, and password fields
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Method to check if the password meets the standard security criteria
  bool isPasswordValid(String password) {
    // Regex: min 6 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special character
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{6,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Method to handle the signup process
  Future<void> doUserSignup() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      _showMessage("❌ All fields are required");
      return;
    }

    if (!isPasswordValid(password)) {
      _showMessage(
        "❌ Password must be at least 6 characters long and include:\n• Uppercase letter\n• Lowercase letter\n• Number\n• Special character (e.g. !@#\$&*)",
      );
      return;
    }

    final user = ParseUser(username, password, email);
    final response = await user.signUp();

    if (response.success) {
      _showMessage("✅ Signup successful! Please login.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      _showMessage("❌ Signup failed: ${response.error?.message}");
    }
  }

  // Method to display a message using SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Username input field
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),

            // Email input field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            // Password input field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            // Password guideline for users
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Password must be at least 6 characters and include:\n• Uppercase & lowercase letters\n• A number\n• A special character (e.g. !@#\$&*)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // Signup button
            ElevatedButton(
              onPressed: doUserSignup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
