import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'machinery_booking_screen.dart';

class MachineryScreen extends StatelessWidget {
  const MachineryScreen({super.key});

  static const List<Map<String, String>> _machines = [
    {'name': 'Tractor', 'desc': 'Powerful tractor for plowing, hauling and field prep.', 'icon': '🚜', 'phone': '+91 98765 00001'},
    {'name': 'Harvester', 'desc': 'Combine harvester for efficient grain & paddy collection.', 'icon': '🌾', 'phone': '+91 98765 00002'},
    {'name': 'Rotavator', 'desc': 'Soil tilling for fine seedbed preparation.', 'icon': '⚙️', 'phone': '+91 98765 00003'},
    {'name': 'Seeder', 'desc': 'Precision seed sowing machine for rows and spacing.', 'icon': '🌱', 'phone': '+91 98765 00004'},
    {'name': 'Sprayer', 'desc': 'High-pressure sprayer for pesticides and fertilizers.', 'icon': '💧', 'phone': '+91 98765 00005'},
    {'name': 'Thresher', 'desc': 'Separates grain from stalks quickly and efficiently.', 'icon': '🏭', 'phone': '+91 98765 00006'},
    {'name': 'Cultivator', 'desc': 'Inter-row weed control and soil aeration machine.', 'icon': '🔧', 'phone': '+91 98765 00007'},
    {'name': 'Plough', 'desc': 'Deep soil turning and preparation for kharif/rabi crops.', 'icon': '🪛', 'phone': '+91 98765 00008'},
    {'name': 'Baler', 'desc': 'Compresses crop residue into compact rectangular bales.', 'icon': '📦', 'phone': '+91 98765 00009'},
    {'name': 'Leveller', 'desc': 'Laser leveller for perfect irrigation field flattening.', 'icon': '📐', 'phone': '+91 98765 00010'},
  ];

  Future<void> _callOwner(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Call $phone')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Farm Machinery Rental', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rent the Right Machine', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Book farm machinery at your doorstep', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _machines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = _machines[i];
                return _MachineryCard(
                  machine: m,
                  onCall: () => _callOwner(context, m['phone']!),
                  onBook: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MachineryBookingScreen(machineName: m['name']!)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineryCard extends StatelessWidget {
  final Map<String, String> machine;
  final VoidCallback onCall;
  final VoidCallback onBook;

  const _MachineryCard({required this.machine, required this.onCall, required this.onBook});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(machine['icon']!, style: const TextStyle(fontSize: 36))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(machine['name']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: 4),
                  Text(machine['desc']!, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryGreen,
                            side: BorderSide(color: primaryGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: onCall,
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                          ),
                          onPressed: onBook,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
