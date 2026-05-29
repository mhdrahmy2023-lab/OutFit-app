import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'payment_methods_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _isDark = false;

  // Language options: English, Tamil, Sinhala
  String _selectedLanguage = 'English';
  final List<Map<String, String>> _languages = [
    {'code': 'English', 'label': 'English'},
    {'code': 'Tamil (தமிழ்)', 'label': 'Tamil (தமிழ்)'},
    {'code': 'Sinhala (සිංහල)', 'label': 'Sinhala (සිංහල)'},
  ];

  // Fix 1 — Currencies: LKR, USD, INR (NO EUR)
  String _selectedCurrency = 'LKR';
  final List<Map<String, String>> _currencies = [
    {'code': 'LKR', 'symbol': 'Rs', 'label': 'LKR – Sri Lankan Rupee'},
    {'code': 'USD', 'symbol': '\$', 'label': 'USD – US Dollar'},
    {'code': 'INR', 'symbol': '₹', 'label': 'INR – Indian Rupee'},
  ];

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Language',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._languages.map((lang) {
                final isSelected = _selectedLanguage == lang['code'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLanguage = lang['code']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryRed.withOpacity(0.08)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryRed
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang['label']!,
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryRed
                                  : Colors.black87,
                            )),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: AppTheme.primaryRed, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Currency',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._currencies.map((cur) {
              final isSelected = _selectedCurrency == cur['code'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCurrency = cur['code']!);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryRed.withOpacity(0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryRed
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            cur['symbol']!,
                            style: GoogleFonts.lato(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(cur['label']!,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primaryRed
                                : Colors.black87,
                          )),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppTheme.primaryRed, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selCur = _currencies.firstWhere((c) => c['code'] == _selectedCurrency,
        orElse: () => _currencies.first);

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
                color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        title: Text('Settings',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ACCOUNT ──
            _SectionLabel(label: 'ACCOUNT'),
            const SizedBox(height: 12),
            _SettingsItem(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            _SettingsItem(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _SettingsItem(
              icon: Icons.payment_outlined,
              label: 'Payment Methods',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen())),
            ),
            const SizedBox(height: 32),

            // ── PREFERENCES ──
            _SectionLabel(label: 'PREFERENCES'),
            const SizedBox(height: 12),

            // Push Notifications
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined,
                      size: 22, color: Colors.black87),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Push Notifications',
                        style: GoogleFonts.lato(
                            fontSize: 15, color: Colors.black87)),
                  ),
                  Switch(
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                    activeThumbColor: AppTheme.primaryRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Language
            GestureDetector(
              onTap: _showLanguagePicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.language_outlined,
                        size: 22, color: Colors.black87),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Language',
                          style: GoogleFonts.lato(
                              fontSize: 15, color: Colors.black87)),
                    ),
                    Text(_selectedLanguage,
                        style: GoogleFonts.lato(
                            color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Currency — Fix 1: LKR, USD, INR
            GestureDetector(
              onTap: _showCurrencyPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange,
                        size: 22, color: Colors.black87),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Currency',
                          style: GoogleFonts.lato(
                              fontSize: 15, color: Colors.black87)),
                    ),
                    Text(
                      '${selCur['code']}  ${selCur['symbol']}',
                      style: GoogleFonts.lato(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Theme
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.palette_outlined,
                      size: 22, color: Colors.black87),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Theme',
                        style: GoogleFonts.lato(
                            fontSize: 15, color: Colors.black87)),
                  ),
                  _ThemeToggle(
                    isDark: _isDark,
                    onChanged: (v) => setState(() => _isDark = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          letterSpacing: 1.5));
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black87),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style:
                        GoogleFonts.lato(fontSize: 15, color: Colors.black87)),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final Function(bool) onChanged;
  const _ThemeToggle({required this.isDark, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        height: 36,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: !isDark ? AppTheme.primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LIGHT',
                    style: GoogleFonts.lato(
                        color: !isDark ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('DARK',
                    style: GoogleFonts.lato(
                        color: isDark ? Colors.white : Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ),
          ],
        ),
      );
}
