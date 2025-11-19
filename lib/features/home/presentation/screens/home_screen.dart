// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart'; // <-- IMPORT
import 'package:vetsy_app/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:vetsy_app/features/home/presentation/screens/clinic_list_screen.dart';
import 'package:vetsy_app/features/pet/presentation/screens/my_pets_screen.dart';
import 'package:vetsy_app/features/profile/presentation/screens/profile_screen.dart';

final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  HomeScreen() : super(key: homeScreenKey); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _widgetOptions = <Widget>[
    const ClinicListScreen(),
    const MyPetsScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
  ];
  
  static const List<String> _titles = <String>[
    'Daftar Klinik', 'Hewan Saya', 'Jadwal Saya', 'Profil Saya',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToTab(int index) {
    if (index < 0 || index >= _widgetOptions.length) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: const [],
      ),
      // BUNGKUS IndexedStack DENGAN WIDGET BARU
      body: ResponsiveConstraintBox(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Klinik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Hewan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}