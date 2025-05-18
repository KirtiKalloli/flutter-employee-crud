import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// DeleteEmployeePage:
/// This screen displays all employees in a grid-style layout and
/// allows the user to delete any employee after confirmation.
/// The data is fetched from the Back4App Parse Server backend.
class DeleteEmployeePage extends StatefulWidget {
  const DeleteEmployeePage({Key? key}) : super(key: key);

  @override
  State<DeleteEmployeePage> createState() => _DeleteEmployeePageState();
}

class _DeleteEmployeePageState extends State<DeleteEmployeePage> {
  List<ParseObject> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEmployees(); // Load data when screen opens
  }

  /// Fetches employee data from the Parse Server (Back4App)
  /// and populates the employee list
  Future<void> loadEmployees() async {
    setState(() => isLoading = true);
    try {
      final response =
          await QueryBuilder<ParseObject>(ParseObject('Employee')).find();

      if (mounted) {
        setState(() {
          employees = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading employees: $e')));
      }
    }
  }

  /// Deletes an employee record after showing confirmation dialog
  Future<void> deleteEmployee(ParseObject emp) async {
    // Ask user to confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete ${emp.get<String>('first_name')}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return; // If user cancels, do nothing

    // Proceed to delete from Parse
    final response = await emp.delete();
    if (response.success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Employee deleted')));
      await loadEmployees(); // Reload list after deletion
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: ${response.error?.message}')),
      );
    }
  }

  /// Builds a card UI for each employee record showing their info
  /// and a delete button
  Widget buildEmployeeCard(ParseObject emp) {
    final name =
        "${emp.get<String>('first_name') ?? ''} ${emp.get<String>('last_name') ?? ''}";
    final empId = emp.get<String>('employee_id') ?? '';
    final email = emp.get<String>('email_id') ?? '';
    final mobile = emp.get<String>('mobile_number') ?? '';
    final age = emp.get<int>('age')?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("ID: $empId", style: const TextStyle(fontSize: 14)),
            Text("Email: $email", style: const TextStyle(fontSize: 14)),
            Text("Mobile: $mobile", style: const TextStyle(fontSize: 14)),
            Text("Age: $age", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => deleteEmployee(emp),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Delete"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main build method for the screen layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delete Employees")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading
              : employees.isEmpty
              ? const Center(child: Text("No employees found")) // No records
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        employees
                            .map(
                              (emp) => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: buildEmployeeCard(emp),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
    );
  }
}
