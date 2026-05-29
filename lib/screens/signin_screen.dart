import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;

  // Validation state
  String? _emailError;
  String? _passError;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(email.trim());
  }

  Future<void> _trySignIn() async {
    setState(() {
      _emailError = null;
      _passError  = null;

      final email    = _emailCtrl.text.trim();
      final password = _passCtrl.text;

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

    if (_emailError != null || _passError != null) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(
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
                        Text(
                          'OUT fIT',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
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
                          child: Text(
                            'SIGN IN',
                            style: GoogleFonts.playfairDisplay(
                                color: AppTheme.primaryRed, fontSize: 28,
                                fontWeight: FontWeight.bold, letterSpacing: 4),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Email ──
                        _FieldLabel(label: 'Email Address'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.lato(),
                          onChanged: (_) { if (_emailError != null) setState(() => _emailError = null); },
                          decoration: InputDecoration(
                            hintText: 'name@domain.com',
                            hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
                            errorText: _emailError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _emailError != null ? AppTheme.primaryRed : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _emailError != null ? AppTheme.primaryRed : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _emailError != null ? AppTheme.primaryRed : Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Password ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel(label: 'Password'),
                            TextButton(
                              onPressed: () {},
                              child: Text('FORGOT PASSWORD?',
                                  style: GoogleFonts.lato(
                                      color: AppTheme.primaryRed, fontSize: 12,
                                      fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
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

                        // ── Continue button ──
                        ElevatedButton(
                          onPressed: _isLoading ? null : _trySignIn,
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
                              : Text('Continue',
                                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 24),

                        // ── Divider ──
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR JOIN WITH',
                                  style: GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 12, letterSpacing: 1)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Social buttons ──
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
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.lato(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'Register',
                                    style: GoogleFonts.lato(color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
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

// ── Shared widgets ────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));
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
