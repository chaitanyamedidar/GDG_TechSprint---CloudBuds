
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/mobile/screens/mobile_main_screen.dart';

const Color offWhite = Color(0xFFF5F5F7);
const Color lavenderAccent = Color(0xFFE6E6FA);
const Color blackButton = Color(0xFF1A1A1A);
const Color greyText = Color(0xFF8A8A8E);

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleSignIn() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && userCredential.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MobileMainScreen(user: userCredential.user!)),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              _buildHeader(),
              const SizedBox(height: 60),
              _buildSignInForm(),
              const SizedBox(height: 30),
              _buildActionButton(),
              const SizedBox(height: 24),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: blackButton,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        'Sign In',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: lavenderAccent, shape: BoxShape.circle),
          child: const Icon(Icons.shield_outlined, size: 40, color: blackButton),
        ),
        const SizedBox(height: 20),
        Text('SafeLabs', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: blackButton)),
        const SizedBox(height: 8),
        Text('Secure Campus IoT Monitor', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: greyText)),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildTextField(controller: _emailController, icon: Icons.email_outlined, hint: 'University Email'),
        const SizedBox(height: 16),
        _buildTextField(controller: _passwordController, icon: Icons.lock_outline, hint: 'Password', obscureText: true),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String hint, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: greyText.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: greyText),
        suffixIcon: obscureText ? const Icon(Icons.visibility_outlined, color: greyText) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Forgot Password? ',
          style: GoogleFonts.inter(color: greyText, fontWeight: FontWeight.w500),
          children: [TextSpan(text: 'Get Help', style: GoogleFonts.inter(color: blackButton, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}
