
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/desktop/invite_user_dialog.dart';
import 'package:safe_labs/desktop/settings_edit_admin_profile.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);
const Color _accentColor = Color(0xFF3F51B5);

class UserManagementScreen extends StatelessWidget {
  final VoidCallback onViewAll;
  const UserManagementScreen({super.key, required this.onViewAll});

  Future<void> _inviteUser(BuildContext context) async {
    final userData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const InviteUserDialog(),
    );

    if (userData == null || !context.mounted) return;

    try {
      final results = await FirebaseFunctions.instance.httpsCallable('inviteUser').call(userData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(results.data['result'])));
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 30),
          _buildAdminList(context),
          const SizedBox(height: 40),
          _buildGlobalAccessRules(context),
          const SizedBox(height: 40),
          _buildEmergencyOverrides(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Management', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor)),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                text: 'Manage access for ',
                style: GoogleFonts.inter(color: _subTextColor, fontSize: 16),
                children: [TextSpan(text: '12 Lab Assistants', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _accentColor))],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _inviteUser(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Invite New User'),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: const Color(0xFF2E3A59), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
        ),
      ],
    );
  }

  Widget _buildAdminList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Administrators', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
            InkWell(onTap: onViewAll, child: Text('View All', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _accentColor))),
          ],
        ),
        const SizedBox(height: 20),
        _buildAdminTile(context, 'Anya Sharma', 'Lab 308', 'https://placehold.co/100x100/FFC107/000000?text=AS', '2 mins ago', 'anya.sharma@uni.edu', true),
        const SizedBox(height: 15),
        _buildAdminTile(context, 'John Doe', 'Physics Lab A', 'https://placehold.co/100x100/3F51B5/FFFFFF?text=JD', '2 days ago', 'john.doe@uni.edu', false),
      ],
    );
  }

  Widget _buildAdminTile(BuildContext context, String name, String lab, String imageUrl, String lastLogin, String email, bool isLabAssistant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 10),
                  if (isLabAssistant) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('LAB ASSISTANT', style: GoogleFonts.inter(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 10))),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [const Icon(Icons.assignment_ind_outlined, size: 16, color: _subTextColor), const SizedBox(width: 5), Text('Assigned to: $lab', style: GoogleFonts.inter(color: _subTextColor))],
              ),
            ],
          ),
          const Spacer(),
          Text('Last Login: $lastLogin', style: GoogleFonts.inter(color: _subTextColor)),
          const SizedBox(width: 30),
          InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditAdminProfileScreen(name: name, lab: lab, imageUrl: imageUrl, email: email))),
            child: Text('Edit Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalAccessRules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Global Access Rules', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: _accentColor, child: Icon(Icons.phonelink_lock_outlined, color: Colors.white)),
              const SizedBox(width: 15),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Require 2FA for Admin Login', style: TextStyle(fontWeight: FontWeight.bold)), Text('All administrators must use two-factor authentication.', style: TextStyle(color: _subTextColor, fontSize: 12))])),
              Switch(value: true, onChanged: (val) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('2FA has been ${val ? 'enabled' : 'disabled'}'))), activeColor: _accentColor,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyOverrides(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Emergency Overrides', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.shade200, width: 1.5)),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              const SizedBox(width: 20),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency Overrides', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)), Text('This action will immediately sever all external connections to the lab infrastructure. Use only in case of active cyber-threat.', style: TextStyle(color: Colors.red, fontSize: 12))])),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campus-Wide Shutdown Initiated!'))),
                icon: const Icon(Icons.power_settings_new, size: 18),
                label: const Text('Initiate Campus-Wide Shutdown'),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red, backgroundColor: Colors.white, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.red)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
