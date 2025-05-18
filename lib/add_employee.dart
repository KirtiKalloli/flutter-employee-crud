import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// AddEmployeePage:
/// This screen allows users to input and submit employee details
/// to the Back4App Parse database. The form includes validation for
/// required fields and ensures that the age field is numeric.
class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({Key? key}) : super(key: key);

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  // Controllers to manage user input from TextFields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final mobileController = TextEditingController();
  final employeeIdController = TextEditingController();
  final emailController = TextEditingController();

  /// Function to save a new employee record to the Parse Server database
  Future<void> addEmployee() async {
    // Retrieve and trim input values
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final empId = employeeIdController.text.trim();
    final ageText = ageController.text.trim();

    // Validate that no fields are empty
    if ([
      firstName,
      lastName,
      email,
      mobile,
      empId,
      ageText,
    ].any((v) => v.isEmpty)) {
      _showMessage("❗ All fields are required.");
      return;
    }

    // Ensure age is a valid numeric input
    final age = int.tryParse(ageText);
    if (age == null) {
      _showMessage("❗ Age must be a valid number.");
      return;
    }

    // Create a new ParseObject for the Employee class
    final employee =
        ParseObject('Employee')
          ..set('first_name', firstName)
          ..set('last_name', lastName)
          ..set('email_id', email)
          ..set('mobile_number', mobile)
          ..set('employee_id', empId)
          ..set('age', age);

    // Save the employee record to Back4App
    final response = await employee.save();

    // Show result message and clear fields if successful
    if (response.success) {
      _showMessage("✅ Employee record added successfully.");
      _clearFields();
    } else {
      _showMessage("❌ Failed to save: ${response.error?.message}");
    }
  }

  /// Clears all input fields after successful submission
  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    ageController.clear();
    mobileController.clear();
    employeeIdController.clear();
    emailController.clear();
  }

  /// Displays a message using SnackBar
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Helper method to build labeled TextFields for user input
  Widget buildInputField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Main widget tree rendering the form UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Build input fields for each employee attribute
              buildInputField(firstNameController, 'First Name'),
              buildInputField(lastNameController, 'Last Name'),
              buildInputField(emailController, 'Email ID'),
              buildInputField(mobileController, 'Mobile Number'),
              buildInputField(employeeIdController, 'Employee ID'),
              buildInputField(
                ageController,
                'Age',
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Submission button
              ElevatedButton(
                onPressed: addEmployee,
                child: const Text("Add Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
