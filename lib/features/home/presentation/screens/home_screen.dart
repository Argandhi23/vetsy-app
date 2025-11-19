import 'package:flutter/material.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/booking/presentation/screens/my_bookings_screen.dart';
import 'package:vetsy_app/features/home/presentation/widgets/home_tab_view.dart'; // Import Baru
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
    const HomeTabView(), // <-- GANTI INI (Sebelumnya ClinicListScreen)
    const MyPetsScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
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
      backgroundColor: Colors.grey[50],
      // APP BAR DIHAPUS KARENA KITA PAKAI CUSTOM HEADER DI HOME
      // appBar: AppBar(...), <-- HAPUS BAGIAN INI
      
      body: ResponsiveConstraintBox(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: 'Hewan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}