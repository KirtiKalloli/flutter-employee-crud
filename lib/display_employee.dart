import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// DisplayEmployeePage:
/// This screen fetches all employee records from the Parse Server
/// and displays them in a scrollable list. Each record is rendered
/// using a card-based ListTile layout.
class DisplayEmployeePage extends StatefulWidget {
  const DisplayEmployeePage({super.key});

  @override
  State<DisplayEmployeePage> createState() => _DisplayEmployeePageState();
}

class _DisplayEmployeePageState extends State<DisplayEmployeePage> {
  // List to store employee records retrieved from Back4App
  List<ParseObject> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees(); // Automatically load data when screen opens
  }

  /// Fetches all employee records from the 'Employee' class on Back4App.
  /// If successful, updates the UI with the data.
  Future<void> fetchEmployees() async {
    final List<ParseObject> results =
        await QueryBuilder<ParseObject>(ParseObject('Employee')).find();

    if (results.isNotEmpty) {
      if (mounted) {
        setState(() {
          employees = results;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No employee records found.")),
        );
      }
    }
  }

  /// Builds a card widget for displaying a single employee's data
  Widget employeeCard(ParseObject emp) {
    // Retrieve individual fields with null safety
    final firstName = emp.get<String>('first_name') ?? '';
    final lastName = emp.get<String>('last_name') ?? '';
    final email = emp.get<String>('email_id') ?? '';
    final empId = emp.get<String>('employee_id') ?? '';
    final mobile = emp.get<String>('mobile_number') ?? '';
    final age = emp.get<int>('age') ?? 0;

    // Return a card-style tile containing employee data
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        title: Text("$firstName $lastName (ID: $empId)"),
        subtitle: Text("Email: $email, Age: $age, Mobile: $mobile"),
        isThreeLine: true,
      ),
    );
  }

  /// Main screen layout rendering all employee cards
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Employees")),
      body:
          employees.isEmpty
              ? const Center(child: CircularProgressIndicator()) // Show loader
              : ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) => employeeCard(employees[index]),
              ),
    );
  }
}
