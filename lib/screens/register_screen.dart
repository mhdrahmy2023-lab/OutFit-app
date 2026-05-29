import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signin_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;

  // Validation errors
  String? _nameError;
  String? _emailError;
  String? _passError;

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(email.trim());

  Future<void> _tryRegister() async {
    setState(() {
      _nameError  = null;
      _emailError = null;
      _passError  = null;

      final name     = _nameCtrl.text.trim();
      final email    = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      if (name.isEmpty) {
        _nameError = 'Name is required';
      }

      if (email.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Please enter a valid email address';
      }

      if (password.isEmpty) {
        _passError = 'Password is required';
      } else if (password.length < 6) {
        _passError = 'Password must be at least 6 characters';
      }
    });

    if (_nameError != null || _emailError != null || _passError != null) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUp(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthService.friendlyError(e)),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFFFF4B5C), Color(0xFFFFC0C0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _BackButton(onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/images/logo.jpg',
                              width: 34, height: 34, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Text('OUT fIT',
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Form Card ──
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('REGISTER',
                              style: GoogleFonts.playfairDisplay(
                                  color: AppTheme.primaryRed, fontSize: 28,
                                  fontWeight: FontWeight.bold, letterSpacing: 4)),
                        ),
                        const SizedBox(height: 36),

                        // ── Name ──
                        _FieldLabel(label: 'Name'),
                        const SizedBox(height: 8),
                        _StyledField(
                          controller: _nameCtrl,
                          hint: 'Mohamed Rahmy',
                          errorText: _nameError,
                          onChanged: (_) { if (_nameError != null) setState(() => _nameError = null); },
                        ),
                        const SizedBox(height: 20),

                        // ── Email ──
                        _FieldLabel(label: 'Email Address'),
                        const SizedBox(height: 8),
                        _StyledField(
                          controller: _emailCtrl,
                          hint: 'name@domain.com',
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) { if (_emailError != null) setState(() => _emailError = null); },
                        ),
                        const SizedBox(height: 20),

                        // ── Password ──
                        _FieldLabel(label: 'Password'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          style: GoogleFonts.lato(),
                          onChanged: (_) { if (_passError != null) setState(() => _passError = null); },
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            errorText: _passError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade500),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _passError != null ? AppTheme.primaryRed : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _passError != null ? AppTheme.primaryRed : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _passError != null ? AppTheme.primaryRed : Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Register button ──
                        ElevatedButton(
                          onPressed: _isLoading ? null : _tryRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text('Register',
                                  style: GoogleFonts.lato(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 24),

                        // ── Divider ──
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR CONTINUE WITH',
                                  style: GoogleFonts.lato(
                                      color: Colors.grey.shade400, fontSize: 12, letterSpacing: 1)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: 'GOOGLE',
                                icon: Icons.g_mobiledata,
                                onTap: () async {
                                  final name = await AuthService.signInWithGoogle();
                                  if (name != null && context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                                      (r) => false,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _SocialButton(
                                label: 'APPLE ID',
                                icon: Icons.apple,
                                onTap: () async {
                                  final cred = await AuthService.signInWithApple();
                                  if (cred != null && context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                                      (r) => false,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignInScreen()),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.lato(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: GoogleFonts.lato(
                                        color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const _StyledField({
    required this.controller,
    required this.hint,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.lato(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: errorText != null ? AppTheme.primaryRed : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: errorText != null ? AppTheme.primaryRed : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: errorText != null ? AppTheme.primaryRed : Colors.blue),
          ),
        ),
      );
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _SocialButton({required this.label, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        ),
      );
}
