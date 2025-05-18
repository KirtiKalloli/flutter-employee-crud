import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';

/// Entry point of the Flutter application.
/// Initializes Parse SDK and starts the app.
void main() async {
  // Ensures widget binding and platform services are initialized before using them.
  WidgetsFlutterBinding.ensureInitialized();

  // Back4App Parse Server credentials
  const keyApplicationId = 'WeMQcJRoyuTNzkmP63ovZHBrFtDUrdRIC2Z0hrwe';
  const keyClientKey = 'p5eE9bRB6DfOSfeMtjgOdzHlGJl5gk0VVp9k6D3z';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  // Initializes Parse SDK with Back4App credentials
  await Parse().initialize(
    keyApplicationId, // Application ID from Back4App
    keyParseServerUrl, // Server URL
    clientKey: keyClientKey, // Client Key from Back4App
    autoSendSessionId: true, // Automatically handles user sessions
    debug: true, // Enables detailed logs for debugging
  );

  // Runs the main Flutter app
  runApp(MyApp());
}

/// MyApp:
/// Root widget of the application. Sets up the MaterialApp,
/// disables the debug banner, and starts at the LoginPage.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // First screen to show on app launch
      debugShowCheckedModeBanner: false, // Removes the debug ribbon
    );
  }
}
