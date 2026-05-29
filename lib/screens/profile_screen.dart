import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameCtrl = TextEditingController(text: 'Mohamed Rahmy');
  final _emailCtrl = TextEditingController(text: 'mohamed@gmail.com');
  final _addressCtrl = TextEditingController(text: '06 o.p.o. Road kalmunai');

  String? _photoUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = AuthService.currentUser?.email ?? 'mohamed@gmail.com';
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      final bytes = await pickedFile.readAsBytes();

      const cloudName = 'dprj3nn8q';
      const uploadPreset = 'outfit_profile';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'profile_photos'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'profile.jpg',
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        final downloadUrl = jsonData['secure_url'] as String;
        await FirestoreService().updateProfilePhoto(downloadUrl);
        setState(() {
          _photoUrl = downloadUrl;
          _isUploadingPhoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Profile photo updated!', style: GoogleFonts.lato()),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        throw Exception(jsonData['error']?['message'] ?? 'Upload failed');
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error uploading photo: $e', style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getUserProfileStream(),
        builder: (context, snapshot) {
          final data = snapshot.hasData && snapshot.data!.exists
              ? snapshot.data!.data() as Map<String, dynamic>? ?? {}
              : {};

          if (!_isEditing) {
            if (data['name'] != null) _nameCtrl.text = data['name'];
            if (data['address'] != null) _addressCtrl.text = data['address'];
          }

          if (data['photoUrl'] != null && !_isEditing) {
            _photoUrl = data['photoUrl'];
          }

          return Stack(
            children: [
              // Red header
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4B5C), Color(0xFFE8253A)],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // App bar row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onBack ??
                                  () {}, // FIX 3: back from profile
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()),
                              ),
                              child: const Icon(Icons.settings,
                                  color: Colors.black87, size: 26),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.primaryRed, width: 3),
                            ),
                            child: ClipOval(
                              child: _isUploadingPhoto
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryRed,
                                      ),
                                    )
                                  : _photoUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: _photoUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(
                                              color: AppTheme.primaryRed,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                              color: Colors.grey.shade200,
                                              child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                              ),
                                         )
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                           child: Icon(
                                           Icons.person,
                                           size: 60,
                                           color: Colors.grey.shade400,
                                           ),
                                         )
                            ),
                          ),
                          if (_isEditing && _photoUrl != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text('Remove profile photo?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Remove',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      final userId =
                                          AuthService.currentUser?.uid;
                                      if (userId != null) {
                                        // 1. Delete the file from Firebase Storage

                                        // 2. Update Firestore
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .update({'photoUrl': null});

                                        // 3. Set _photoUrl = null in state
                                        setState(() {
                                          _photoUrl = null;
                                        });

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Profile photo removed')),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint(
                                          'Error removing profile photo: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          if (_isEditing && !_isUploadingPhoto)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadPhoto,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // White card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _ProfileField(
                                label: 'Name',
                                controller: _nameCtrl,
                                enabled: _isEditing),
                            const SizedBox(height: 16),
                            _ProfileField(
                                label: 'Email',
                                controller: _emailCtrl,
                                enabled: _isEditing),
                            const SizedBox(height: 16),
                            _ProfileField(
                              label: 'Delivery Address',
                              controller: _addressCtrl,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 24),
                            _MenuRow(
                                label: 'Payment Details',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PaymentMethodsScreen()))),
                            const SizedBox(height: 12),
                            _MenuRow(
                                label: 'Order History',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const OrdersScreen()))),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (_isEditing) {
                                        await FirestoreService()
                                            .updateUserProfile(
                                          name: _nameCtrl.text,
                                          address: _addressCtrl.text,
                                        );
                                      }
                                      setState(() => _isEditing = !_isEditing);
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppTheme.darkBrown,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.edit_outlined,
                                              color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isEditing
                                                ? 'Save Profile'
                                                : 'Edit Profile',
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const WelcomeScreen()),
                                      (r) => false,
                                    ),
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.black87, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Log out',
                                            style: GoogleFonts.lato(
                                              color: AppTheme.primaryRed,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.logout,
                                              color: AppTheme.primaryRed,
                                              size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.lato(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryRed),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
