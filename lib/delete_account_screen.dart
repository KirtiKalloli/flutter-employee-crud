import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// This screen allows a user to delete their Parse account after
/// verifying their credentials. It includes form validation,
/// login verification, and confirmation before deletion.
class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state during deletion
  bool _isDeleting = false;

  /// Handles the account deletion process:
  /// - Validates the form
  /// - Authenticates the user
  /// - Deletes the user if login is successful
  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isDeleting = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Authenticate user with Parse Server
    final user = ParseUser(username, password, null);
    final loginResponse = await user.login();

    if (loginResponse.success) {
      // Delete account of currently logged-in user
      final currentUser = await ParseUser.currentUser() as ParseUser;
      final deleteResponse = await currentUser.delete();

      if (deleteResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Account deleted successfully.")),
        );

        // Navigate back to the first route (e.g., login screen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showError("❌ Account deletion failed. Please try again.");
      }
    } else {
      _showError(
        "❌ Invalid credentials. Please check your username or password.",
      );
    }

    setState(() {
      _isDeleting = false;
    });
  }

  /// Helper to show error messages using a red snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Builds the delete account form and user interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Please confirm your credentials to delete your account.',
              ),
              const SizedBox(height: 20),

              // Username input field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Enter username' : null,
              ),

              // Password input field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value!.isEmpty ? 'Enter password' : null,
              ),

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Delete button or loading spinner
              _isDeleting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _deleteAccount,
                    child: const Text('Delete Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
