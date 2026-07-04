import 'package:cloud_firestore/cloud_firestore.dart';

class PlantedCrop {
  final String id;
  final String userId;
  final String cropName;
  final double acreage;
  final DateTime plantingDate;
  final String status; // 'growing', 'harvested'
  final List<String> reminderIds;

  PlantedCrop({
    required this.id,
    required this.userId,
    required this.cropName,
    required this.acreage,
    required this.plantingDate,
    this.status = 'growing',
    this.reminderIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropName': cropName,
      'acreage': acreage,
      'plantingDate': Timestamp.fromDate(plantingDate),
      'status': status,
      'reminderIds': reminderIds,
    };
  }

  factory PlantedCrop.fromMap(Map<String, dynamic> map, String id) {
    return PlantedCrop(
      id: id,
      userId: map['userId'] ?? '',
      cropName: map['cropName'] ?? '',
      acreage: (map['acreage'] ?? 0.0).toDouble(),
      plantingDate: (map['plantingDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'growing',
      reminderIds: List<String>.from(map['reminderIds'] ?? []),
    );
  }

  PlantedCrop copyWith({
    String? id,
    String? userId,
    String? cropName,
    double? acreage,
    DateTime? plantingDate,
    String? status,
    List<String>? reminderIds,
  }) {
    return PlantedCrop(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropName: cropName ?? this.cropName,
      acreage: acreage ?? this.acreage,
      plantingDate: plantingDate ?? this.plantingDate,
      status: status ?? this.status,
      reminderIds: reminderIds ?? this.reminderIds,
    );
  }
}
