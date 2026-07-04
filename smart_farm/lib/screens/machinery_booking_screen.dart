import 'package:flutter/material.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';

class MachineryBookingScreen extends StatefulWidget {
  final String machineName;
  const MachineryBookingScreen({super.key, required this.machineName});

  @override
  State<MachineryBookingScreen> createState() => _MachineryBookingScreenState();
}

class _MachineryBookingScreenState extends State<MachineryBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a booking date.')));
      return;
    }
    setState(() => _isSubmitting = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    // Navigate to confirmation screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _BookingConfirmationScreen(
          machineName: widget.machineName,
          userName: _nameController.text.trim(),
          date: _selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${TranslationService.translate('book')} ${widget.machineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Machine chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.agriculture, color: primaryGreen),
                    const SizedBox(width: 10),
                    Text('${TranslationService.translate('booking')}: ${widget.machineName}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Theme.of(context).primaryColor : const Color(0xFF1B5E20), fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(TranslationService.translate('your_details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),

              _buildFormCard(context, [
                _field(context, _nameController, TranslationService.translate('full_name'), Icons.person, validator: (v) => v!.isEmpty ? TranslationService.translate('enter_name') : null),
                const SizedBox(height: 14),
                _field(context, _phoneController, TranslationService.translate('mobile_number'), Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? TranslationService.translate('enter_valid_mobile') : null),
                const SizedBox(height: 14),
                _field(context, _addressController, TranslationService.translate('farm_address'), Icons.location_on,
                    maxLines: 3, validator: (v) => v!.isEmpty ? TranslationService.translate('enter_address') : null),
                const SizedBox(height: 14),
                _field(context, _hoursController, TranslationService.translate('hours_required'), Icons.timer,
                    keyboard: TextInputType.number,
                    validator: (v) => v!.isEmpty ? TranslationService.translate('enter_hours') : null),
              ]),

              const SizedBox(height: 16),
              Text(TranslationService.translate('booking_date'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _selectedDate == null ? (isDark ? Colors.white12 : Colors.grey.shade300) : primaryGreen),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: primaryGreen),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? TranslationService.translate('tap_select_date')
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal,
                          color: _selectedDate != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSubmitting ? null : _submitBooking,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: FarmLoader.small())
                      : const Icon(Icons.check_circle_outline),
                  label: Text(TranslationService.translate('submit_booking'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard, int maxLines = 1, String? Function(String?)? validator}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen, size: 20),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF6FAF2),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ─── Confirmation Screen ───────────────────────────────────────────────────────

class _BookingConfirmationScreen extends StatelessWidget {
  final String machineName;
  final String userName;
  final DateTime date;

  const _BookingConfirmationScreen({
    required this.machineName,
    required this.userName,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success animation
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryGreen, width: 3),
                  ),
                  child: Icon(Icons.check_circle, color: primaryGreen, size: 70),
                ),
                const SizedBox(height: 28),
                Text(TranslationService.translate('booking_confirmed'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen)),
                const SizedBox(height: 12),
                Text(
                  TranslationService.translate('machine_booked_success'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                ),
                const SizedBox(height: 24),
                // Booking summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _row(context, Icons.agriculture, TranslationService.translate('machine'), machineName),
                      const Divider(height: 20),
                      _row(context, Icons.person, TranslationService.translate('name'), userName),
                      const Divider(height: 20),
                      _row(context, Icons.calendar_today, TranslationService.translate('date'), '${date.day}/${date.month}/${date.year}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Simulated notification
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.amber.withOpacity(0.05) : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.amber.withOpacity(0.2) : const Color(0xFFFFCC02)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: isDark ? Colors.amber : const Color(0xFFF57F17)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          TranslationService.translate('sms_sent'),
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.amber.withOpacity(0.8) : const Color(0xFF795548)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(TranslationService.translate('back_to_shop'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 18),
        const SizedBox(width: 10),
        Text('$label:', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ],
    );
  }
}
