import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class GeneralProfileScreen extends StatefulWidget {
  const GeneralProfileScreen({super.key});

  @override
  State<GeneralProfileScreen> createState() => _GeneralProfileScreenState();
}

class _GeneralProfileScreenState extends State<GeneralProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final results = await FirebaseFunctions.instance.httpsCallable('getDashboardData').call();
      if (mounted) {
        final userData = Map<String, dynamic>.from(results.data['user']);
        setState(() {
          _userData = userData;
          _nameController.text = _userData?['full_name'] ?? '';
          _emailController.text = _userData?['email'] ?? '';
          // Using placeholders for fields not in the database
          _phoneController.text = '+1 (555) 019-2834';
          _departmentController.text = 'Science & Technology';
          _isLoading = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to load profile data.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 30),
          _buildProfileCard(context),
          const SizedBox(height: 30),
          _buildPersonalInfoCard(context),
          const SizedBox(height: 30),
          _buildRegionalPrefsCard(context),
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
            Text('General Profile', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor)),
            const SizedBox(height: 5),
            Text('Manage your personal information and account preferences.', style: GoogleFonts.inter(color: _subTextColor, fontSize: 16)),
          ],
        ),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved successfully!'))),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3A59),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final String avatarUrl = _userData?['avatar_url'] as String? ?? '';
    final String initial = _userData?['full_name']?[0] ?? 'D';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? Text(initial, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)) : null,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userData?['full_name'] ?? 'Campus Dean', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: _textColor)),
              const SizedBox(height: 5),
              Text('Campus Dean - ID: #${_userData?['user_id'] ?? '00000'}', style: GoogleFonts.inter(color: _subTextColor)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload new photo...'))),
            child: const Text('Upload New Photo'),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo removed.'))),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField('Full Name', _nameController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('University Email', _emailController)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField('Phone Number', _phoneController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Department', _departmentController, isLocked: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isLocked = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _subTextColor, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isLocked,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            suffixIcon: isLocked ? const Icon(Icons.lock_outline, size: 16) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionalPrefsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Regional Preferences', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdownField('Language', ['English (US)', 'English (UK)'], 'English (US)')),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdownField('Timezone', ['(GMT-05:00) Eastern Time', '(GMT-08:00) Pacific Time'], '(GMT-05:00) Eastern Time')),
            ],
          ),
        ],
      ),
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
