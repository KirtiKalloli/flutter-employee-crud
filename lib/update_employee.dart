import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// A screen that displays employee information in a grid layout,
/// allows editing, and updates the record in Back4App.
class UpdateEmployeePage extends StatefulWidget {
  final ParseObject employee;

  const UpdateEmployeePage({super.key, required this.employee});

  @override
  State<UpdateEmployeePage> createState() => _UpdateEmployeePageState();
}

class _UpdateEmployeePageState extends State<UpdateEmployeePage> {
  // Text controllers for each employee field
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController empIdController;
  late TextEditingController ageController;
  late TextEditingController mobileController;

  // Flags for edit mode and loading state
  bool isEditable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Initializes all text controllers with values from the passed-in employee object.
  void _initializeControllers() {
    firstNameController = TextEditingController(
      text: widget.employee.get<String>('first_name'),
    );
    lastNameController = TextEditingController(
      text: widget.employee.get<String>('last_name'),
    );
    emailController = TextEditingController(
      text: widget.employee.get<String>('email_id'),
    );
    empIdController = TextEditingController(
      text: widget.employee.get<String>('employee_id'),
    );
    ageController = TextEditingController(
      text: widget.employee.get<int>('age').toString(),
    );
    mobileController = TextEditingController(
      text: widget.employee.get<String>('mobile_number'),
    );
  }

  /// Updates the employee record in the Parse Server (Back4App).
  Future<void> updateEmployee() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Validate that age is numeric
      final age = int.tryParse(ageController.text.trim());
      if (age == null) {
        _showMessage("❌ Age must be numeric.");
        return;
      }

      // Create a new ParseObject and assign updated values
      final updated =
          ParseObject('Employee')
            ..objectId = widget.employee.objectId
            ..set('first_name', firstNameController.text.trim())
            ..set('last_name', lastNameController.text.trim())
            ..set('email_id', emailController.text.trim())
            ..set('employee_id', empIdController.text.trim())
            ..set('mobile_number', mobileController.text.trim())
            ..set('age', age);

      // Save updated object to server
      final response = await updated.save();

      if (!mounted) return;

      if (response.success) {
        // Update local object to reflect changes
        widget.employee
          ..set('first_name', firstNameController.text.trim())
          ..set('last_name', lastNameController.text.trim())
          ..set('email_id', emailController.text.trim())
          ..set('employee_id', empIdController.text.trim())
          ..set('mobile_number', mobileController.text.trim())
          ..set('age', age);

        _showMessage("✅ Employee updated successfully");
        setState(() => isEditable = false);
      } else {
        _showMessage("❌ Error: ${response.error?.message}");
      }
    } catch (e) {
      if (mounted) {
        _showMessage("❌ Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a SnackBar with the provided message.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Builds a styled text field with optional input type and read-only toggle.
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? inputType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType ?? TextInputType.text,
        readOnly: !isEditable, // Enable editing only if in edit mode
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !isEditable,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to free resources
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    empIdController.dispose();
    ageController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Employee'),
        actions: [
          // Cancel button in edit mode to revert changes
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  isEditable = false;
                  _initializeControllers(); // Reset to original values
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grid layout for employee fields
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: [
                _buildTextField('First Name', firstNameController),
                _buildTextField('Last Name', lastNameController),
                _buildTextField('Employee ID', empIdController),
                _buildTextField(
                  'Age',
                  ageController,
                  inputType: TextInputType.number,
                ),
                _buildTextField(
                  'Mobile Number',
                  mobileController,
                  inputType: TextInputType.phone,
                ),
                _buildTextField(
                  'Email',
                  emailController,
                  inputType: TextInputType.emailAddress,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Show 'Edit' button only in read-only mode
                if (!isEditable)
                  ElevatedButton(
                    onPressed: () => setState(() => isEditable = true),
                    child: const Text("Edit"),
                  ),
                // Show 'Save' button in editable mode
                if (isEditable)
                  ElevatedButton(
                    onPressed: _isLoading ? null : updateEmployee,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Save"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
