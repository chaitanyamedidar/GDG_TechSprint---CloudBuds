import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/desktop/settings_all_admins.dart';
import 'package:safe_labs/desktop/settings_general_profile.dart';
import 'package:safe_labs/desktop/settings_notifications.dart';
import 'package:safe_labs/desktop/settings_system_security.dart';
import 'package:safe_labs/desktop/settings_user_management.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);
const Color _accentColor = Color(0xFF3F51B5);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCategory = 'User Management';

  void _navigateToAllAdmins() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AllAdminsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsSidebar(),
        Expanded(child: _buildSettingsContent()),
      ],
    );
  }

  Widget _buildSettingsSidebar() {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONFIGURATION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _subTextColor, fontSize: 12)),
          const SizedBox(height: 20),
          _buildSettingsNavItem(Icons.person_outline, 'General Profile'),
          _buildSettingsNavItem(Icons.group_outlined, 'User Management'),
          _buildSettingsNavItem(Icons.security_outlined, 'System Security'),
          _buildSettingsNavItem(Icons.notifications_outlined, 'Notifications'),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _accentColor.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SYSTEM STATUS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _accentColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('All systems operational. Last backup 2 hours ago.', style: GoogleFonts.inter(color: _subTextColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsNavItem(IconData icon, String title) {
    final bool isSelected = _selectedCategory == title;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? Colors.grey.shade200 : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [Icon(icon, color: _subTextColor), const SizedBox(width: 12), Text(title, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: _textColor))],),
      ),
    );
  }

  Widget _buildSettingsContent() {
    switch (_selectedCategory) {
      case 'User Management':
        return UserManagementScreen(onViewAll: _navigateToAllAdmins);
      case 'General Profile':
        return const GeneralProfileScreen();
      case 'System Security':
        return const SystemSecurityScreen();
      case 'Notifications':
        return const NotificationsScreen();
      default:
        return UserManagementScreen(onViewAll: _navigateToAllAdmins);
    }
  }
}
