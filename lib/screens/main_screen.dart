import 'package:flutter/material.dart';
import 'package:interquatier/screens/events/events_menu_screen.dart';
import 'package:interquatier/screens/common/coming_soon_screen.dart';
import 'package:interquatier/screens/home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsMenuScreen(),
    const ComingSoonScreen(title: 'Chat', message: 'Chat feature coming soon!'),
    const ComingSoonScreen(title: 'Profile', message: 'Profile feature coming soon!'),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('MainScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MainScreen, selectedIndex: $_selectedIndex');
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          debugPrint('Navigation index changed to: $index');
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_basketball_rounded),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 