import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';
import 'package:flutter/foundation.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Stream<List<Reminder>> getUserReminders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('global_reminders')
        .where('userId', isEqualTo: user.uid)
        // .orderBy('dateTime') // Disabled to avoid index error
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reminder.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addReminder(Reminder reminder) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      final docRef = await _firestore
          .collection('global_reminders')
          .add(reminder.toMap());
          
      final newReminder = reminder.copyWith(id: docRef.id);
      
      if (newReminder.isActive) {
        await scheduleLocalNotification(newReminder);
      }
    } catch (e) {
      debugPrint("Error adding reminder: $e");
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('global_reminders')
          .doc(reminder.id)
          .update(reminder.toMap());
          
      // Cancel existing schedule
      await _localNotifications.cancel(id: reminder.id.hashCode);
      
      if (reminder.isActive) {
        await scheduleLocalNotification(reminder);
      }
    } catch (e) {
      debugPrint("Error updating reminder: $e");
    }
  }

  Future<void> deleteReminder(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore
          .collection('global_reminders')
          .doc(id)
          .delete();
          
      await _localNotifications.cancel(id: id.hashCode);
    } catch (e) {
      debugPrint("Error deleting reminder: $e");
    }
  }

  Future<void> toggleReminderStatus(Reminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    await updateReminder(updatedReminder);
  }

  Future<void> scheduleLocalNotification(Reminder reminder) async {
    // Skip if time is in the past and no repeat
    if (reminder.dateTime.isBefore(DateTime.now()) && reminder.repeatType == 'None') {
      return;
    }

    final int notificationId = reminder.id.hashCode;
    
    var scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);
    // Ensure if it's daily/weekly, we step it forward if it was scheduled for the past 
    if (reminder.dateTime.isBefore(DateTime.now())) {
       if (reminder.repeatType == 'Daily') {
         while (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
           scheduledDate = scheduledDate.add(const Duration(days: 1));
         }
       } else if (reminder.repeatType == 'Weekly') {
         while (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
           scheduledDate = scheduledDate.add(const Duration(days: 7));
         }
       }
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'farming_reminders',
      'Farming Reminders',
      channelDescription: 'Notifications for crop care, watering, etc.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    DateTimeComponents? matchTime;
    if (reminder.repeatType == 'Daily') {
      matchTime = DateTimeComponents.time;
    } else if (reminder.repeatType == 'Weekly') {
      matchTime = DateTimeComponents.dayOfWeekAndTime;
    }

    await _localNotifications.zonedSchedule(
      id: notificationId,
      title: 'Krushi Mithra',
      body: reminder.description.isNotEmpty ? '${reminder.title}\n${reminder.description}' : reminder.title,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchTime,
    );
    
    debugPrint("Scheduled Local Notification for ${scheduledDate.toString()}");
  }
}
