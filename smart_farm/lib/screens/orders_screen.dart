import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Cache the last known list so items never vanish during transient loading states
  List<QueryDocumentSnapshot> _lastOrders = [];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(TranslationService.translate('my_orders'))),
        body: Center(child: Text(TranslationService.translate('login_to_view_orders'))),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen = isDark ? Theme.of(context).primaryColor : const Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: Text(TranslationService.translate('my_orders'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Update cache only when we have real data
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            _lastOrders = snapshot.data!.docs;
          }

          // Still loading and no cache yet — show spinner
          if (snapshot.connectionState == ConnectionState.waiting && _lastOrders.isEmpty) {
            return Center(child: FarmLoader(size: 60, color: primaryGreen));
          }

          // Confirmed empty from Firestore (not just loading)
          if (snapshot.connectionState != ConnectionState.waiting &&
              snapshot.hasData &&
              snapshot.data!.docs.isEmpty &&
              _lastOrders.isEmpty) {
            return Center(child: Text(TranslationService.translate('no_orders_found'), style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)));
          }

          // Use cached list so scroll never causes vanishing
          final orders = _lastOrders;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final order = orders[i].data() as Map<String, dynamic>;
              return Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white10 : Colors.transparent)),
                elevation: isDark ? 0 : 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${TranslationService.translate('order_hash')}${orders[i].id}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 6),
                      Text('${TranslationService.translate('status')} ${order['status'] ?? TranslationService.translate('unknown')}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      Text('${TranslationService.translate('total')} ₹${order['totalAmount'] ?? '--'}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      Text(
                          '${TranslationService.translate('date')} ${order['timestamp']?.toDate().toString().split(' ')[0] ?? '--'}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      const SizedBox(height: 8),
                      Text(TranslationService.translate('items'),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      ...List<Widget>.from(
                        (order['items'] as List?)?.map((item) => Text(
                                '${item['productName']} x${item['quantity']} - ₹${item['total']}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))) ??
                            [],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
