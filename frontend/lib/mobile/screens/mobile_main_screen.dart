
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/mobile/screens/mobile_ai_chat_screen.dart';
import 'package:safe_labs/mobile/screens/mobile_dashboard_screen.dart';
import 'package:safe_labs/mobile/screens/mobile_profile_screen.dart';

const Color lavender = Color(0xFFE6E6FA);
const Color blackText = Color(0xFF1A1A1A);
const Color greyText = Color(0xFF8A8A8E);

class MobileMainScreen extends StatefulWidget {
  final User user;
  const MobileMainScreen({super.key, required this.user});

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _widgetOptions = <Widget>[
      const MobileDashboardScreen(),
      const MobileAIChatScreen(),
      MobileProfileScreen(user: widget.user),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            border: const Border(top: BorderSide(color: Colors.black12, width: 0.5)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: MediaQuery.of(context).padding.bottom + 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.grid_view_rounded, 'Labs', 0),
                _buildNavItem(Icons.auto_awesome_outlined, 'AI', 1),
                _buildNavItem(Icons.person_outline, 'Profile', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: isSelected
          ? _buildActiveNavItem(icon, label)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: greyText, size: 28),
                const SizedBox(height: 4),
                Text(label, style: GoogleFonts.inter(color: greyText, fontWeight: FontWeight.w500))
              ],
            ),
    );
  }

  Widget _buildActiveNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: lavender,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: blackText, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: blackText))
      ],
    );
  }
}
