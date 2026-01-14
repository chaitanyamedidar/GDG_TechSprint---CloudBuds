
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class EditAdminProfileScreen extends StatelessWidget {
  final String name;
  final String lab;
  final String imageUrl;
  final String email;

  const EditAdminProfileScreen({super.key, required this.name, required this.lab, required this.imageUrl, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Administrator Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            _buildDetailsCard(context),
            const SizedBox(height: 30),
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: _textColor)),
              const SizedBox(height: 5),
              Text('Administrator', style: GoogleFonts.inter(color: _subTextColor)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E3A59), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField('Full Name', name)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Email Address', email)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdownField('Assigned Lab', ['Lab 308', 'Physics Lab A', 'Biology Dept.'], lab)),
              const Expanded(child: SizedBox()), // Keep alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
          const SizedBox(height: 20),
          _buildActionButton(context, title: 'Reset Password', subtitle: 'Send a password reset link to the user\'s email.', buttonText: 'Send Link', onButtonPressed: () {}),
          const Divider(height: 40),
          _buildActionButton(context, title: 'Deactivate User', subtitle: 'This will remove their access and mark the account as inactive.', buttonText: 'Deactivate', onButtonPressed: () {}, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _subTextColor, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _subTextColor, fontSize: 12)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: (_) {},
          decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required String title, required String subtitle, required String buttonText, required VoidCallback onButtonPressed, bool isDestructive = false}) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: _subTextColor, fontSize: 12))])),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title action performed.'))),
          style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? Colors.red : const Color(0xFF2E3A59), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20)),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
