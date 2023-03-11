import 'package:flutter/material.dart';

class DarkModeScreen extends StatefulWidget {
  @override
  _DarkModeScreenState createState() => _DarkModeScreenState();
}

class _DarkModeScreenState extends State<DarkModeScreen> {
  bool _isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dark Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enable Dark Mode',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Switch(
              value: _isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _isDarkModeEnabled = value;
                });

                if (_isDarkModeEnabled) {
                  // Enable dark mode
                  _setDarkMode();
                } else {
                  // Disable dark mode
                  _setLightMode();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setDarkMode() {
    // Configure the theme for dark mode
    ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.blueGrey[900],
      accentColor: Colors.blueGrey[600],
      scaffoldBackgroundColor: Colors.blueGrey[900],
      appBarTheme: AppBarTheme(
        color: Colors.blueGrey[900],
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyText2: TextStyle(
          color: Colors.white,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    );

    // Set the app's theme to dark mode
    _applyTheme(darkTheme);
  }

  void _setLightMode() {
    // Configure the theme for light mode
    ThemeData lightTheme = ThemeData.light();

    // Set the app's theme to light mode
    _applyTheme(lightTheme);
  }

  void _applyTheme(ThemeData theme) {
    // Update the app's theme
    MaterialApp app = MaterialApp(
      title: 'My App',
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: Container(),
      ),
    );

    // Replace the root widget with the updated app
    runApp(app);
  }
}
