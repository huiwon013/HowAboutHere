import 'package:flutter/material.dart';
import 'package:hah/community/c_all_posts.dart'; // 커뮤니티 페이지 import
import 'package:hah/mainpage/home.dart'; // 홈 페이지 import
import 'package:hah/mypage/mypage.dart';


class AppBarWithBottomNav extends StatefulWidget {
  const AppBarWithBottomNav({super.key});

  @override
  State<AppBarWithBottomNav> createState() => _AppBarWithBottomNavState();
}

class _AppBarWithBottomNavState extends State<AppBarWithBottomNav> {
  int _selectedIndex = 1; // 기본 홈 페이지로 설정

  final List<Widget> _pages = [
    const CommunityPage(),
    const HomeScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '개인정보',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
