import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _cardNumCtrl  = TextEditingController();
  final _holderCtrl   = TextEditingController();
  final _expiryCtrl   = TextEditingController();
  final _cvvCtrl      = TextEditingController();
  bool _showAddCard   = false;
  int _selectedCard   = 0; // 0 = Mastercard, 1 = Visa

  final List<Map<String, String>> _savedCards = [
    {'type': 'mastercard', 'number': '5132 **** **** 4565', 'label': 'Credit Card'},
    {'type': 'visa',       'number': '9632 **** **** 2461', 'label': 'Debit Card'},
  ];

  @override
  void dispose() {
    _cardNumCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_cardNumCtrl.text.isEmpty || _holderCtrl.text.isEmpty ||
        _expiryCtrl.text.isEmpty || _cvvCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all card details',
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final maskedNum = '**** **** **** ${_cardNumCtrl.text.replaceAll(' ', '').substring(
        (_cardNumCtrl.text.replaceAll(' ', '').length - 4).clamp(0, 999999)
    )}';
    setState(() {
      _savedCards.add({'type': 'visa', 'number': maskedNum, 'label': 'Visa Debit Card'});
      _cardNumCtrl.clear();
      _holderCtrl.clear();
      _expiryCtrl.clear();
      _cvvCtrl.clear();
      _showAddCard = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card added successfully!',
            style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        title: Text('Payment Methods',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Saved Cards ────────────────────────────────────────────
            Text('Saved Cards',
                style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            ..._savedCards.asMap().entries.map((e) {
              final i = e.key;
              final card = e.value;
              final isSelected = _selectedCard == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCard = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.darkBrown
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      // Card brand logo area
                      Container(
                        width: 52,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.15)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 0.5),
                        ),
                        child: Center(
                          child: _CardBrandIcon(
                              type: card['type']!,
                              isSelected: isSelected),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card['label']!,
                                style: GoogleFonts.lato(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                )),
                            const SizedBox(height: 3),
                            Text(card['number']!,
                                style: GoogleFonts.lato(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.65)
                                      : Colors.grey.shade500,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                      // Radio indicator
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── Add New Card ────────────────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _showAddCard = !_showAddCard),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _showAddCard
                        ? AppTheme.primaryRed
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: AppTheme.primaryRed, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text('Add New Card',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87)),
                    const Spacer(),
                    Icon(
                      _showAddCard
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            // ── Add Card Form (expandable) ──────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showAddCard
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Details',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Card Number
                    _CardField(
                      controller: _cardNumCtrl,
                      label: 'Card Number',
                      hint: '1234  5678  9012  3456',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      maxLength: 19,
                    ),
                    const SizedBox(height: 14),

                    // Card Holder Name
                    _CardField(
                      controller: _holderCtrl,
                      label: 'Card Holder Name',
                      hint: 'Full name as on card',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 14),

                    // Expiry + CVV
                    Row(
                      children: [
                        Expanded(
                          child: _CardField(
                            controller: _expiryCtrl,
                            label: 'MM / YY',
                            hint: '08 / 28',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryFormatter(),
                            ],
                            maxLength: 5,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CardField(
                            controller: _cvvCtrl,
                            label: 'CVV',
                            hint: '•••',
                            keyboardType: TextInputType.number,
                            obscure: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Visa Debit Card Option ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          // Visa card visual
                          Container(
                            width: 64,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A1F71),
                                  Color(0xFF1565C0)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('VISA',
                                  style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Visa Debit Card',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.black87)),
                                Text('Accepted worldwide',
                                    style: GoogleFonts.lato(
                                        color: Colors.grey.shade500,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Selected',
                                style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save card button
                    ElevatedButton(
                      onPressed: _saveCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Save Card',
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Card brand icon ───────────────────────────────────────────────────────────
class _CardBrandIcon extends StatelessWidget {
  final String type;
  final bool isSelected;
  const _CardBrandIcon({required this.type, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (type == 'visa') {
      return Text('VISA',
          style: GoogleFonts.lato(
              color: isSelected ? Colors.white : const Color(0xFF1A1F71),
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5));
    }
    // Mastercard circles
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 6,
          child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                  color: Colors.red.shade600.withOpacity(0.9),
                  shape: BoxShape.circle)),
        ),
        Positioned(
          right: 6,
          child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.85),
                  shape: BoxShape.circle)),
        ),
      ],
    );
  }
}

// ── Card form field ───────────────────────────────────────────────────────────
class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure;
  final int? maxLength;

  const _CardField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscure = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: GoogleFonts.lato(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
            counterText: '',
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppTheme.primaryRed)),
          ),
        ),
      ],
    );
  }
}

// ── Input formatters ──────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    var text = val.text.replaceAll('  ', '').replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return val.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    var text = val.text.replaceAll(' / ', '').replaceAll('/', '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)} / ${text.substring(2)}';
    }
    return val.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
