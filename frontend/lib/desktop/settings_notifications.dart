
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Preferences', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor)),
          const SizedBox(height: 5),
          Text('Customize how you receive system alerts.', style: GoogleFonts.inter(color: _subTextColor, fontSize: 16)),
          const SizedBox(height: 30),
          _buildCard(
            context,
            title: 'Where to send alerts',
            child: Column(
              children: [
                _buildSwitchRow('Push Notifications', true, (val) {}),
                const Divider(height: 30),
                _buildSwitchRow('Email Notifications', true, (val) {}),
                const Divider(height: 30),
                _buildSwitchRow('SMS Alerts', false, (val) {}),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildCard(
            context,
            title: 'Trigger Basis',
            child: Column(
              children: [
                _buildSwitchRow('Critical Events', true, (val) {}),
                const Divider(height: 30),
                _buildSwitchRow('Unforeseen failures', true, (val) {}),
                const Divider(height: 30),
                _buildSwitchRow('Periodic health checks', false, (val) {}),
                const Divider(height: 30),
                _buildSwitchRow('Incomplete backups', true, (val) {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        Switch(value: value, onChanged: onChanged),
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
