
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/desktop/settings_edit_admin_profile.dart';

const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class AllAdminsScreen extends StatelessWidget {
  const AllAdminsScreen({super.key});

  // Mock data that would typically come from a database or API
  final List<Map<String, String>> _admins = const [
    {
      'name': 'Anya Sharma',
      'lab': 'Lab 308',
      'imageUrl': 'https://placehold.co/100x100/FFC107/000000?text=AS',
      'email': 'anya.sharma@uni.edu',
    },
    {
      'name': 'John Doe',
      'lab': 'Physics Lab A',
      'imageUrl': 'https://placehold.co/100x100/3F51B5/FFFFFF?text=JD',
      'email': 'john.doe@uni.edu',
    },
    {
      'name': 'Dr. Evelyn Reed',
      'lab': 'Biology Dept.',
      'imageUrl': 'https://placehold.co/100x100/4CAF50/FFFFFF?text=ER',
      'email': 'evelyn.reed@uni.edu',
    },
    {
      'name': 'Marcus Chen',
      'lab': 'IT Support',
      'imageUrl': 'https://placehold.co/100x100/F44336/FFFFFF?text=MC',
      'email': 'marcus.chen@uni.edu',
    },
    {
      'name': 'Sarah Williams',
      'lab': 'Robotics Wing',
      'imageUrl': 'https://placehold.co/100x100/9C27B0/FFFFFF?text=SW',
      'email': 'sarah.williams@uni.edu',
    },
  ];

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
        title: Text('All Active Administrators', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _textColor)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(30),
        itemCount: _admins.length,
        separatorBuilder: (context, index) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final admin = _admins[index];
          return _buildAdminTile(context, admin['name']!, admin['lab']!, admin['imageUrl']!, admin['email']!);
        },
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, String name, String lab, String imageUrl, String email) {
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
              Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text('Assigned to: $lab', style: GoogleFonts.inter(color: _subTextColor)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditAdminProfileScreen(name: name, lab: lab, imageUrl: imageUrl, email: email))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E3A59), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
