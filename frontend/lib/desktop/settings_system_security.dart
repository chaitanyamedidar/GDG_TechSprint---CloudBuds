
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class SystemSecurityScreen extends StatelessWidget {
  const SystemSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Security', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor)),
          const SizedBox(height: 30),
          _buildLoginRequirementsCard(context),
          const SizedBox(height: 30),
          _buildChangePasswordCard(context),
          const SizedBox(height: 30),
          _buildEmergencyLockdownCard(context),
          const SizedBox(height: 30),
          _buildWhereYoureLoggedInCard(context),
        ],
      ),
    );
  }

  Widget _buildLoginRequirementsCard(BuildContext context) {
    return _buildCard(
      context,
      title: 'Login Requirements',
      child: Column(
        children: [
          _buildSwitchRow('Require 2-Factor Authentication', 'All administrators must use two-factor authentication', true, (val) {}),
          const Divider(height: 30),
          _buildSwitchRow('Allow social sign-in', 'Enable sign-in with Google or other social providers', false, (val) {}),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard(BuildContext context) {
    return _buildCard(
      context,
      title: 'Change Master Password',
      child: Row(
        children: [
          const Expanded(child: TextField(obscureText: true, decoration: InputDecoration(labelText: 'Current Password'))),
          const SizedBox(width: 20),
          const Expanded(child: TextField(obscureText: true, decoration: InputDecoration(labelText: 'New Password'))),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
            child: const Text('Set Password'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyLockdownCard(BuildContext context) {
    return _buildCard(
      context,
      title: 'Emergency Lockdown',
      child: Row(
        children: [
          const Expanded(child: Text('This will sign out all active users and suspend all access until manually re-enabled.')),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
            child: const Text('Initiate Lockdown'),
          ),
        ],
      ),
    );
  }

  Widget _buildWhereYoureLoggedInCard(BuildContext context) {
    return _buildCard(
      context,
      title: 'Where you\'re signed in',
      child: Column(
        children: [
          _buildDeviceRow(Icons.desktop_windows, 'Chrome on Windows', 'Current session'),
          const Divider(height: 30),
          _buildDeviceRow(Icons.phone_iphone, 'iPhone 14 Pro', '2 hours ago'),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: _subTextColor, fontSize: 12))])),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDeviceRow(IconData icon, String device, String lastActive) {
    return Row(
      children: [
        Icon(icon, color: _subTextColor),
        const SizedBox(width: 15),
        Expanded(child: Text(device, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(lastActive, style: const TextStyle(color: _subTextColor)),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
