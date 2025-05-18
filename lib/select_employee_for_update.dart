import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'update_employee.dart';

/// A screen that displays a list of all employees from Back4App (Parse Server),
/// allowing the user to select one for updating their details.
class SelectEmployeeForUpdatePage extends StatefulWidget {
  const SelectEmployeeForUpdatePage({super.key});

  @override
  State<SelectEmployeeForUpdatePage> createState() =>
      _SelectEmployeeForUpdatePageState();
}

class _SelectEmployeeForUpdatePageState
    extends State<SelectEmployeeForUpdatePage> {
  // List to store all employee records fetched from the server
  List<ParseObject> employees = [];

  // Loading state indicator
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEmployees(); // Fetch employees when the page initializes
  }

  /// Fetches employee records from the 'Employee' class on the Parse Server
  Future<void> loadEmployees() async {
    setState(() => _isLoading = true); // Show loading spinner

    try {
      // Query all employee objects
      final response =
          await QueryBuilder<ParseObject>(ParseObject('Employee')).find();

      // If the widget is still mounted, update the UI with the fetched data
      if (mounted) {
        setState(() {
          employees = response; // Assign the response to local list
          _isLoading = false; // Hide loading spinner
        });
      }
    } catch (e) {
      // On error, show a snackbar message and hide the loader
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading employees: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Employee to Update"),
        actions: [
          // Refresh icon in AppBar to reload employee list manually
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadEmployees),
        ],
      ),

      // Show loading spinner or employee list based on loading state
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: loadEmployees, // Pull-to-refresh
                child: ListView.builder(
                  itemCount: employees.length, // Total number of employees
                  itemBuilder: (context, index) {
                    final emp = employees[index];

                    // Safely get employee name and ID
                    final name =
                        "${emp.get<String>('first_name') ?? ''} ${emp.get<String>('last_name') ?? ''}";
                    final id = emp.get<String>('employee_id') ?? '';

                    return ListTile(
                      title: Text(name), // Employee full name
                      subtitle: Text("ID: $id"), // Employee ID
                      trailing: const Icon(Icons.edit),

                      // On tap, navigate to the update screen with the selected employee
                      onTap: () async {
                        final updatedEmployee =
                            await Navigator.push<ParseObject>(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => UpdateEmployeePage(employee: emp),
                              ),
                            );

                        // If employee was updated, replace it in the list
                        if (updatedEmployee != null && mounted) {
                          setState(() {
                            employees[index] = updatedEmployee;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
    );
  }
}
