import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _postalCtrl    = TextEditingController();
  bool _isSaving       = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await FirestoreService().addAddress(
        fullName:    _nameCtrl.text.trim(),
        phone:       _phoneCtrl.text.trim(),
        addressLine: _addressCtrl.text.trim(),
        city:        _cityCtrl.text.trim(),
        postalCode:  _postalCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true); // true = success
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save address. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black87, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        title: Text(
          'ADD ADDRESS',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Full Name ──
              _buildLabel('Full Name'),
              _buildField(
                controller: _nameCtrl,
                hint: 'e.g. Kasun Perera',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 16),

              // ── Phone ──
              _buildLabel('Phone Number'),
              _buildField(
                controller: _phoneCtrl,
                hint: 'e.g. 0771234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.length < 9 ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 16),

              // ── Address Line ──
              _buildLabel('Address'),
              _buildField(
                controller: _addressCtrl,
                hint: 'e.g. No 12, Galle Road',
                icon: Icons.home_outlined,
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 16),

              // ── City ──
              _buildLabel('City'),
              _buildField(
                controller: _cityCtrl,
                hint: 'e.g. Colombo',
                icon: Icons.location_city_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Enter your city' : null,
              ),
              const SizedBox(height: 16),

              // ── Postal Code ──
              _buildLabel('Postal Code'),
              _buildField(
                controller: _postalCtrl,
                hint: 'e.g. 00300',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter postal code' : null,
              ),
              const SizedBox(height: 32),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SAVE ADDRESS',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.lato(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryRed),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
