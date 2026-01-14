import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteUserDialog extends StatefulWidget {
  const InviteUserDialog({super.key});

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _labController = TextEditingController();
  bool _isDean = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _labController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _isDean ? 'CAMPUS_DEAN' : 'LAB_ASSISTANT',
        'lab': _labController.text.trim(),
      };
      Navigator.of(context).pop(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Invite New User', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 20),
              if (!_isDean)
                TextFormField(
                  controller: _labController,
                  decoration: const InputDecoration(labelText: 'Assigned Lab (e.g., Lab 308)'),
                  validator: (value) => !_isDean && value!.isEmpty ? 'Please assign a lab' : null,
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Lab Assistant'),
                  Switch(value: _isDean, onChanged: (val) => setState(() => _isDean = val)),
                  const Text('Campus Dean'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submitForm, child: const Text('Send Invite')),
      ],
    );
  }
}
