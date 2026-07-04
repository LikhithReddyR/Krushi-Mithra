import 'package:flutter/material.dart';
import '../models/planted_crop_model.dart';
import '../services/crop_tracking_service.dart';
import '../services/translation_service.dart';
import 'add_planted_crop_screen.dart';
import '../widgets/fast_page_route.dart';

class MyCropsScreen extends StatefulWidget {
  const MyCropsScreen({super.key});

  @override
  State<MyCropsScreen> createState() => _MyCropsScreenState();
}

class _MyCropsScreenState extends State<MyCropsScreen> {
  final _cropService = CropTrackingService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('my_crops')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, FastPageRoute(page: const AddPlantedCropScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PlantedCrop>>(
        stream: _cropService.getUserPlantedCrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final crops = snapshot.data ?? [];

          if (crops.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crops.length,
            itemBuilder: (context, index) {
              return _buildCropCard(crops[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, FastPageRoute(page: const AddPlantedCropScreen()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(TranslationService.translate('add_crop'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            TranslationService.translate('no_crops_planted'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, FastPageRoute(page: const AddPlantedCropScreen())),
            child: Text(TranslationService.translate('add_crop')),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(PlantedCrop crop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysSincePlanting = DateTime.now().difference(crop.plantingDate).inDays;
    final isHarvested = crop.status == 'harvested';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: isHarvested 
                ? Colors.grey.withOpacity(0.1) 
                : Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHarvested ? Colors.grey : Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.grass, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '${crop.acreage} ${TranslationService.translate('acreage')}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHarvested ? Colors.grey : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isHarvested 
                        ? TranslationService.translate('harvested') 
                        : TranslationService.translate('growing'),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_month,
                    TranslationService.translate('planting_date'),
                    '${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.timeline,
                    'Growth Duration',
                    '$daysSincePlanting days since planting',
                  ),
                  const SizedBox(height: 20),
                  if (!isHarvested)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cropService.markAsHarvested(crop.id),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Mark as Harvested'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => _showDeleteDialog(crop),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text('Crop Cycle Completed', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _showDeleteDialog(crop),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  void _showDeleteDialog(PlantedCrop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop Record?'),
        content: Text('Are you sure you want to remove the tracking for ${crop.cropName}? This will not remove associations from the Reminders screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _cropService.deletePlantedCrop(crop);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
