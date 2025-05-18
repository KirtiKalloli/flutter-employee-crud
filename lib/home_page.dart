import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// Importing other functional screens
import 'add_employee.dart';
import 'delete_employee.dart';
import 'display_employee.dart';
import 'login_page.dart';
import 'select_employee_for_update.dart';

/// HomePage:
/// This is the main dashboard screen after login.
/// It provides navigation to Add, Display, Update, and Delete employee screens,
/// and allows the user to log out of the application.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  /// Logs out the currently logged-in user by calling Parse logout API.
  /// If successful, it redirects the user to the login screen.
  Future<void> doUserLogout(BuildContext context) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final response = await user.logout();
      if (response.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.error?.message}')),
        );
      }
    }
  }

  /// Navigates to the specified widget screen
  void navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Builds the main UI layout with navigation buttons
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Dashboard"),
        actions: [
          // Logout button placed in the top app bar
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text("Logout", style: TextStyle(color: Colors.black)),
            onPressed: () => doUserLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            /// Button to open AddEmployeePage to create new employee records
            ElevatedButton(
              onPressed: () => navigate(context, const AddEmployeePage()),
              child: const Text("➕ Add Employee"),
            ),
            const SizedBox(height: 12),

            /// Button to display all employee records in a list format
            ElevatedButton(
              onPressed: () => navigate(context, const DisplayEmployeePage()),
              child: const Text("📋 Display Employees"),
            ),
            const SizedBox(height: 12),

            /// Button to go to the employee selector before updating
            /// This ensures the correct employee is passed to the update screen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectEmployeeForUpdatePage(),
                  ),
                );
              },
              child: const Text("✏️ Update Employee"),
            ),
            const SizedBox(height: 12),

            /// Button to go to the DeleteEmployeePage for record removal
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeleteEmployeePage()),
                );
              },
              child: const Text("🗑️ Delete Employee"),
            ),
          ],
        ),
      ),
    );
  }
}
