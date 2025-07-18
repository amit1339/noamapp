import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'firebase_options.dart'; // Add this import (generated by flutterfire configure)
import 'login.dart';
import 'home_page.dart';
import 'customers_page.dart';
import 'map_page.dart';
import 'schedule_page.dart';
import 'settings.dart';
import 'translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use the generated options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(), // Start with the login screen
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Change from a list of widgets to a list of widget builder functions
  static final List<Widget Function()> _pageBuilders = <Widget Function()>[
    () => HomePage(),
    () => CustomersPage(),
    () => MapPage(),
    () => SchedulePage(),
  ];

  final List<String> _titles = ['home', 'customers', 'map', 'schedule'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.text(_titles[_selectedIndex])),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            setState(() {}); // Rebuild to reflect language change
          },
        ),
      ),
      // Build the selected page each time
      body: _pageBuilders[_selectedIndex](),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: Translations.text('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: Translations.text('customers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: Translations.text('map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: Translations.text('schedule'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
