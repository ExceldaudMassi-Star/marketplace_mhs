// PERBAIKAN UNTUK: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:marketplace_mhs/screens/profile_screen.dart';
import 'package:marketplace_mhs/screens/chat_screen.dart';
import 'package:marketplace_mhs/screens/favorites_screen.dart';
import 'package:marketplace_mhs/widgets/home_tab_view.dart';
import 'package:marketplace_mhs/widgets/nav_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeTabView(),
    const ChatScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BARIS INI YANG DIPERBAIKI ---
      // Mencegah layout terdorong ke atas saat keyboard muncul
      resizeToAvoidBottomInset: false,
      // ---------------------------------
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_product'),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 2.0,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              NavButton(
                icon: Icons.home_filled,
                label: "Home",
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              NavButton(
                icon: Icons.chat_bubble_outline,
                label: "Chat",
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              const SizedBox(width: 40),
              NavButton(
                icon: Icons.favorite_border,
                label: "Favorit",
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              NavButton(
                icon: Icons.person_outline,
                label: "Profil",
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
