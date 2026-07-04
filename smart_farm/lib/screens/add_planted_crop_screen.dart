import 'package:flutter/material.dart';
import '../services/crop_tracking_service.dart';
import '../services/translation_service.dart';
import '../widgets/farm_loader.dart';

class AddPlantedCropScreen extends StatefulWidget {
  const AddPlantedCropScreen({super.key});

  @override
  State<AddPlantedCropScreen> createState() => _AddPlantedCropScreenState();
}

class _AddPlantedCropScreenState extends State<AddPlantedCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _acreageController = TextEditingController();
  final _cropService = CropTrackingService();
  
  String? _selectedCrop;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCrop = _cropService.getSupportedCrops().first;
  }

  @override
  void dispose() {
    _acreageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) return;

    setState(() => _isSubmitting = true);
    
    await _cropService.addPlantedCrop(
      _selectedCrop!,
      double.parse(_acreageController.text),
      _selectedDate,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('save_crop')),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('add_crop')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(TranslationService.translate('crop_name')),
              const SizedBox(height: 8),
              _buildCropDropdown(),
              
              const SizedBox(height: 24),
              _buildSectionTitle(TranslationService.translate('acreage')),
              const SizedBox(height: 8),
              _buildAcreageField(),
              
              const SizedBox(height: 24),
              _buildSectionTitle(TranslationService.translate('planting_date')),
              const SizedBox(height: 8),
              _buildDatePicker(),
              
              const SizedBox(height: 48),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildCropDropdown() {
    final crops = _cropService.getSupportedCrops();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: _selectedCrop,
      items: crops.map((crop) => DropdownMenuItem(
        value: crop,
        child: Text(crop),
      )).toList(),
      onChanged: (val) => setState(() => _selectedCrop = val),
      decoration: _inputDecoration(Icons.grass),
      dropdownColor: Theme.of(context).cardColor,
    );
  }

  Widget _buildAcreageField() {
    return TextFormField(
      controller: _acreageController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Enter acreage';
        if (double.tryParse(val) == null) return 'Enter a valid number';
        return null;
      },
      decoration: _inputDecoration(Icons.straighten).copyWith(
        suffixText: 'Acres',
      ),
    );
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        onPressed: _isSubmitting ? null : _submit,
        child: _isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              TranslationService.translate('save_crop'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}
