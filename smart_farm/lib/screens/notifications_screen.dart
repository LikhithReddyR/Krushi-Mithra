import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _userNotifications = [];
  bool _isLoading = true;
  StreamSubscription? _userSub;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    final user = FirebaseAuth.instance.currentUser;
    
    // Listen to User-Specific Notifications
    if (user != null) {
      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _userNotifications.clear();
          for (var doc in snapshot.docs) {
            _userNotifications.add(doc.data());
          }
          _isLoading = false;
        });
      });
    } else {
      _isLoading = false;
    }
  }

  List<Map<String, dynamic>> get _allNotifications {
    final merged = [..._userNotifications];
    // Sort by timestamp descending
    merged.sort((a, b) {
      final tsA = a['timestamp'] as Timestamp?;
      final tsB = b['timestamp'] as Timestamp?;
      if (tsA == null || tsB == null) return 0;
      return tsB.compareTo(tsA);
    });
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(TranslationService.translate('notifications'), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: FarmLoader(color: Theme.of(context).primaryColor, size: 50))
          : _allNotifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allNotifications.length,
                  itemBuilder: (context, index) {
                    final data = _allNotifications[index];
                    return _buildNotificationItem(data);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text(TranslationService.translate('no_notifications'), style: TextStyle(fontSize: 18, color: isDark ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final type = data['type'] ?? 'info';
    
    IconData icon = Icons.notifications_active;
    Color iconColor = Theme.of(context).primaryColor;
    Color bgColor = Theme.of(context).primaryColor.withOpacity(0.1);

    if (type == 'water_alert') {
      icon = Icons.water_drop;
      iconColor = Colors.blue;
      bgColor = Colors.blue.withOpacity(0.1);
    } else if (type == 'weather') {
      icon = Icons.wb_sunny;
      iconColor = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
    } else if (type == 'offer') {
      icon = Icons.local_offer;
      iconColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
    }

    String timeAgo = TranslationService.translate('just_now');
    if (timestamp != null) {
      final diff = DateTime.now().difference(timestamp.toDate());
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays} ${TranslationService.translate('days_ago')}';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours} ${TranslationService.translate('hours_ago')}';
      } else if (diff.inMinutes > 0) {
        timeAgo = '${diff.inMinutes} ${TranslationService.translate('mins_ago')}';
      }
    }

    return _buildNotificationUI(
      title: title,
      description: body,
      time: timeAgo,
      icon: icon,
      iconColor: iconColor,
      bgColor: bgColor,
    );
  }

  Widget _buildNotificationUI({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color))),
                    Text(time, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
