import 'package:flutter/material.dart';

import 'screens.dart';

void main() {
runApp(const CameraExplorerApp());
}

class CameraExplorerApp extends StatelessWidget {
const CameraExplorerApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,

  title: 'Camera Explorer',

  theme: ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
    ),

    scaffoldBackgroundColor:
        const Color(0xFFF5F7FA),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0757B8),
      foregroundColor: Colors.white,
    ),
  ),

  home: const HomeScreen(),
);

}
}

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() =>
_HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int selectedIndex = 0;

final List<Widget> screens = const [
OrderScreen(),
BeltScreen(),
];

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Camera Explorer',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),

  body: IndexedStack(
    index: selectedIndex,
    children: screens,
  ),

  bottomNavigationBar: NavigationBar(
    selectedIndex: selectedIndex,

    onDestinationSelected: (index) {
      setState(() {
        selectedIndex = index;
      });
    },

    destinations: const [
      NavigationDestination(
        icon: Icon(
          Icons.photo_camera_outlined,
        ),
        selectedIcon: Icon(
          Icons.photo_camera,
        ),
        label: 'The Order',
      ),

      NavigationDestination(
        icon: Icon(Icons.sync),
        selectedIcon: Icon(
          Icons.sync_alt,
        ),
        label: 'The Belt',
      ),
    ],
  ),
);

}
}