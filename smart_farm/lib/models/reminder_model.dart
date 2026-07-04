import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String repeatType; // 'None', 'Daily', 'Weekly'
  final String category; // 'Crop Care', 'Weather', 'Market', 'Other'
  final bool isActive;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateTime,
    this.repeatType = 'None',
    this.category = 'Crop Care',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'repeatType': repeatType,
      'category': category,
      'isActive': isActive,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map, String id) {
    return Reminder(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['dateTime'] != null ? (map['dateTime'] as Timestamp).toDate() : DateTime.now(),
      repeatType: map['repeatType'] ?? 'None',
      category: map['category'] ?? 'Crop Care',
      isActive: map['isActive'] ?? true,
    );
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? repeatType,
    String? category,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      repeatType: repeatType ?? this.repeatType,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }
}
