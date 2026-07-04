import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/planted_crop_model.dart';
import '../models/reminder_model.dart';
import 'reminder_service.dart';

class CropMilestone {
  final String title;
  final int daysFromPlanting;
  final String description;

  CropMilestone({
    required this.title,
    required this.daysFromPlanting,
    required this.description,
  });
}

class CropTrackingService {
  static final CropTrackingService _instance = CropTrackingService._internal();
  factory CropTrackingService() => _instance;
  CropTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ReminderService _reminderService = ReminderService();

  final Map<String, List<CropMilestone>> _cropCycles = {
    'Paddy': [
      CropMilestone(title: 'First Fertilizer Dose', daysFromPlanting: 15, description: 'Apply Urea and Potash for early growth.'),
      CropMilestone(title: 'Second Fertilizer Dose', daysFromPlanting: 45, description: 'Apply Fertilizer for panicle initiation stage.'),
      CropMilestone(title: 'Pest Monitoring', daysFromPlanting: 65, description: 'Check for Stem Borer and Leaf Folder pests.'),
      CropMilestone(title: 'Harvesting', daysFromPlanting: 120, description: 'Crop is ready for harvest. Drain the field.'),
    ],
    'Tomato': [
      CropMilestone(title: 'First Fertilizer Dose', daysFromPlanting: 10, description: 'Support early root development.'),
      CropMilestone(title: 'Second Fertilizer Dose', daysFromPlanting: 30, description: 'Apply during flowering stage.'),
      CropMilestone(title: 'Disease Monitoring', daysFromPlanting: 45, description: 'Check for Late Blight and Fruit Borer.'),
      CropMilestone(title: 'First Harvest', daysFromPlanting: 75, description: 'Start picking ripe tomatoes.'),
    ],
    'Wheat': [
      CropMilestone(title: 'CRI Stage Irrigation & Fertilizer', daysFromPlanting: 21, description: 'Critical stage for root initiation. Apply first dose of Nitrogen.'),
      CropMilestone(title: 'Tillering Stage Fertilizer', daysFromPlanting: 45, description: 'Apply second dose of Nitrogen.'),
      CropMilestone(title: 'Rust Disease Check', daysFromPlanting: 70, description: 'Monitor for yellow or brown rust on leaves.'),
      CropMilestone(title: 'Harvesting', daysFromPlanting: 130, description: 'Harvest when grains are hard and straw is yellow.'),
    ],
    'Maize': [
      CropMilestone(title: 'Thinning & Fertilizer', daysFromPlanting: 15, description: 'Remove extra plants and apply first top dressing.'),
      CropMilestone(title: 'Taseling Stage Fertilizer', daysFromPlanting: 45, description: 'Apply Nitrogen during tassel emergence.'),
      CropMilestone(title: 'Pest Control (Fall Armyworm)', daysFromPlanting: 30, description: 'Monitor closely for Fall Armyworm damage.'),
      CropMilestone(title: 'Harvesting', daysFromPlanting: 110, description: 'Harvest when cob husks have turned golden brown.'),
    ],
    'Chilli': [
      CropMilestone(title: 'Fertilizer Application', daysFromPlanting: 20, description: 'Apply first top dressing of NPK.'),
      CropMilestone(title: 'Flowering Stage Care', daysFromPlanting: 40, description: 'Check for thrips and mites during flowering.'),
      CropMilestone(title: 'First Picking', daysFromPlanting: 70, description: 'Green chillies ready for harvesting.'),
      CropMilestone(title: 'Mature Harvest', daysFromPlanting: 100, description: 'Harvest for dry chilli production.'),
    ],
  };

  List<String> getSupportedCrops() => _cropCycles.keys.toList();

  Stream<List<PlantedCrop>> getUserPlantedCrops() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('planted_crops')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlantedCrop.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addPlantedCrop(String cropName, double acreage, DateTime plantingDate) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final newCropDoc = _firestore.collection('planted_crops').doc();
      final String cropId = newCropDoc.id;

      List<String> reminderIds = [];

      // Generate reminders based on crop milestones
      if (_cropCycles.containsKey(cropName)) {
        for (var milestone in _cropCycles[cropName]!) {
          final milestoneDate = plantingDate.add(Duration(days: milestone.daysFromPlanting));
          
          // Only schedule future reminders
          if (milestoneDate.isAfter(DateTime.now())) {
            final reminder = Reminder(
              id: '', // Will be set by service
              userId: user.uid,
              title: '$cropName: ${milestone.title}',
              description: '${milestone.description} (Area: $acreage acres)',
              dateTime: milestoneDate,
              category: 'Crop Care',
              isActive: true,
            );
            
            // We need a way to get the ID back from addReminder
            // Modifying ReminderService slightly or use a batch might be better, 
            // but let's use the existing service.
            
            // To get ID, we have to wait for addReminder but it doesn't return ID currently.
            // Let's assume we'll fix ReminderService or just not track IDs for now.
            await _reminderService.addReminder(reminder);
          }
        }
      }

      final plantedCrop = PlantedCrop(
        id: cropId,
        userId: user.uid,
        cropName: cropName,
        acreage: acreage,
        plantingDate: plantingDate,
        reminderIds: reminderIds,
      );

      await newCropDoc.set(plantedCrop.toMap());
    } catch (e) {
      debugPrint("Error adding planted crop: $e");
    }
  }

  Future<void> deletePlantedCrop(PlantedCrop crop) async {
    try {
      await _firestore.collection('planted_crops').doc(crop.id).delete();
      // Optionally delete associated reminders, but we don't have their IDs easily now
    } catch (e) {
      debugPrint("Error deleting planted crop: $e");
    }
  }
  
  Future<void> markAsHarvested(String cropId) async {
    try {
      await _firestore.collection('planted_crops').doc(cropId).update({'status': 'harvested'});
    } catch (e) {
      debugPrint("Error marking crop as harvested: $e");
    }
  }
}
