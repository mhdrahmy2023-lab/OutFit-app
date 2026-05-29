import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../screens/add_address_screen.dart';

class AddressSelector extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAddressSelected;

  const AddressSelector({super.key, required this.onAddressSelected});

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getAddressesStream(),
      builder: (context, snapshot) {
        final addresses = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Section title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DELIVERY ADDRESS',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                // Add new address button
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAddressScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: AppTheme.primaryRed, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Add New',
                        style: GoogleFonts.lato(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── No addresses yet ──
            if (addresses.isEmpty)
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddAddressScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryRed,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_location_alt_outlined,
                          color: AppTheme.primaryRed),
                      const SizedBox(width: 12),
                      Text(
                        'Add a delivery address',
                        style: GoogleFonts.lato(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Address cards ──
            ...addresses.map((address) {
              final id         = address['id'] as String;
              final isSelected = _selectedId == id;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedId = id);
                  widget.onAddressSelected(address);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryRed.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryRed
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radio circle
                      Container(
                        width: 22, height: 22,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryRed
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Address details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['fullName'] ?? '',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address['phone'] ?? '',
                              style: GoogleFonts.lato(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address['addressLine']}, ${address['city']}, ${address['postalCode']}',
                              style: GoogleFonts.lato(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete button
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Delete Address',
                                  style: GoogleFonts.playfairDisplay()),
                              content: Text(
                                'Are you sure you want to remove this address?',
                                style: GoogleFonts.lato(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel',
                                      style: GoogleFonts.lato()),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete',
                                      style: GoogleFonts.lato(
                                          color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirestoreService().deleteAddress(id);
                            if (_selectedId == id) {
                              setState(() => _selectedId = null);
                              widget.onAddressSelected(null);
                            }
                          }
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
