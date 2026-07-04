import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_farm/services/ai_scanner_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SoilMoisturePredictorScreen extends StatefulWidget {
  const SoilMoisturePredictorScreen({super.key});

  @override
  State<SoilMoisturePredictorScreen> createState() => _SoilMoisturePredictorScreenState();
}

class _SoilMoisturePredictorScreenState extends State<SoilMoisturePredictorScreen> {
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickedImage;
  String _soilType = 'Loamy';
  final List<String> _soilTypes = ['Loamy', 'Clay', 'Sandy', 'Silty', 'Peaty', 'Saline'];
  
  bool _isLoading = false;
  bool _isAiAnalyzing = false;
  String _predictedLabel = '';
  double _predictedPercent = 0.0;
  String _recommendation = '';
  String _aiInsight = '';

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _rainfallController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1080);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1080);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not capture image.')));
    }
  }

  Future<Position?> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }

  Future<void> _fetchRealMoisture() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _predictedLabel = '';
      _recommendation = '';
      _aiInsight = '';
    });

    try {
      final position = await _getPosition();
      if (position == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _locationController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });

      // Open-Meteo free API for live soil moisture, temp, and humidity
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,precipitation,soil_moisture_0_to_7cm'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        final temp = current['temperature_2m']?.toDouble() ?? 0.0;
        final humidity = current['relative_humidity_2m']?.toDouble() ?? 0.0;
        final rain = current['precipitation']?.toDouble() ?? 0.0;
        
        // Volumetric Water Content (m³/m³) 0.0 to approx 0.50 max
        final soilMoistureVWC = current['soil_moisture_0_to_7cm']?.toDouble() ?? 0.2;

        _temperatureController.text = temp.toString();
        _humidityController.text = humidity.toString();
        _rainfallController.text = rain.toString();

        // Convert VWC to a practical 0-100% moisture reading
        // 0.5 VWC is basically waterlogged. Let's cap at 0.5 for 100%
        double pct = (soilMoistureVWC / 0.5) * 100;
        
        // Slight modifiers for soil type (e.g. sand drains faster, clay holds more)
        pct += _soilType == 'Clay' ? 5 : _soilType == 'Sandy' ? -5 : 0;
        pct = pct.clamp(0, 100);

        String label;
        String rec;
        Color color;

        if (pct < 30) {
          label = 'Low';
          rec = 'Critical! Immediate irrigation needed. Soil is very dry.';
          color = Colors.red.shade600;
        } else if (pct < 60) {
          label = 'Moderate';
          rec = 'Healthy moisture. Standard watering schedule recommended.';
          color = Colors.orange.shade700;
        } else {
          label = 'High';
          rec = 'Avoid watering. Soil is well-hydrated and risks waterlogging.';
          color = Colors.green.shade700;
        }

        setState(() {
          _predictedPercent = pct;
          _predictedLabel = label;
          _recommendation = rec;
          _isLoading = false;
        });

        if (_pickedImage != null) {
          setState(() => _isAiAnalyzing = true);
          final insight = await AiScannerService().analyzeSoil(
            File(_pickedImage!.path),
            temp,
            humidity,
            rain,
            label,
          );
          if (mounted) {
            setState(() {
              _aiInsight = _cleanText(insight);
              _isAiAnalyzing = false;
            });
          }
        }
        // Save to history
        _savePrediction();

      } else {
        throw Exception('Failed to fetch weather data.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrediction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final scanId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(scanId)
          .set({
        'id': scanId,
        'type': 'soil_moisture',
        'temperature': double.tryParse(_temperatureController.text) ?? 0.0,
        'humidity': double.tryParse(_humidityController.text) ?? 0.0,
        'rainfall': double.tryParse(_rainfallController.text) ?? 0.0,
        'soilType': _soilType,
        'predictedLabel': _predictedLabel,
        'predictedPercent': _predictedPercent,
        'recommendation': _recommendation,
        'aiInsight': _aiInsight,
        'imagePath': _pickedImage?.path,
        'timestamp': DateTime.now(),
        'source': 'mobile',
      });
    } catch (e) {
      debugPrint('Failed to save soil prediction: $e');
    }
  }

  Widget _buildInputField({required String label, required TextEditingController controller, String suffixText = '', required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixText: suffixText,
              suffixStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final hintColor = isDark ? Colors.white54 : const Color(0xFF5D5D5D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(TranslationService.translate('soil_moisture_predictor')),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).primaryColor.withOpacity(0.15) : const Color(0xFFECF5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFDDE8DA)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFEACC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grass, color: Color(0xFF3A5D2C), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(TranslationService.translate('check_soil_condition'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                          const SizedBox(height: 4),
                          Text(TranslationService.translate('enter_data_moisture'), style: TextStyle(fontSize: 13, color: hintColor)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(TranslationService.translate('input_data'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_camera, color: Color(0xFF406527)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(TranslationService.translate('upload_capture_soil'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF707070)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_pickedImage != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_pickedImage!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pickedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Center(
                          child: Text(TranslationService.translate('no_image_selected'), style: TextStyle(color: hintColor)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4C7A2B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        readOnly: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: TranslationService.translate('enter_location'),
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final pos = await _getPosition();
                        if (pos != null) {
                          setState(() {
                            _locationController.text = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
                          });
                        }
                      },
                      child: Text(TranslationService.translate('auto_detect')),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: TranslationService.translate('temperature_c'), controller: _temperatureController, suffixText: '°C', context: context)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField(label: TranslationService.translate('humidity_pct'), controller: _humidityController, suffixText: '%', context: context)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: TranslationService.translate('rainfall_mm'), controller: _rainfallController, suffixText: 'mm', context: context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TranslationService.translate('soil_type'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: _soilType,
                            dropdownColor: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: _soilTypes.map((soil) => DropdownMenuItem(value: soil, child: Text(soil, style: TextStyle(color: textColor)))).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _soilType = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: FarmLoader.small()) : const Icon(Icons.satellite_alt, color: Colors.white),
                  label: Text(_isLoading ? TranslationService.translate('checking') : 'Live Satellite Moisture Check', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _fetchRealMoisture,
                ),
              ),

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.03), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TranslationService.translate('result'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.thermostat, color: Color(0xFF3A6A2F)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(TranslationService.translate('soil_moisture_level'), style: const TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_predictedLabel.isEmpty ? TranslationService.translate('unknown') : (TranslationService.translate(_predictedLabel.toLowerCase()) ?? _predictedLabel), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          backgroundColor: _predictedLabel == 'High'
                              ? Colors.green.shade600
                              : _predictedLabel == 'Medium'
                                  ? Colors.orange.shade600
                                  : _predictedLabel == 'Low'
                                      ? Colors.red.shade600
                                      : Colors.grey.shade500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _predictedLabel.isEmpty ? TranslationService.translate('no_prediction_yet') : '${TranslationService.translate('estimated_moisture')}: ${_predictedPercent.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 10),
                    Text(TranslationService.translate('recommendation'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Text(
                      _recommendation.isEmpty
                          ? TranslationService.translate('use_button_advice')
                          : _recommendation,
                      style: TextStyle(fontSize: 14, color: hintColor),
                    ),
                    
                    if (_isAiAnalyzing || _aiInsight.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Text(TranslationService.translate('ai_insight') ?? 'AI Visual Analysis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isAiAnalyzing)
                        const Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('Analyzing soil image...', style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        )
                      else
                        Text(
                          _aiInsight,
                          style: TextStyle(fontSize: 14, color: hintColor),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).primaryColor.withOpacity(0.15) : const Color(0xFFDFF0D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: isDark ? Theme.of(context).primaryColor : const Color(0xFF2B5325)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        TranslationService.translate('tip_accurate_results'),
                        style: TextStyle(color: isDark ? Theme.of(context).primaryColor : const Color(0xFF2F4F31), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _cleanText(String text) {
    // Remove common markdown symbols
    return text
        .replaceAll(RegExp(r'\*\*'), '') // Remove bold
        .replaceAll(RegExp(r'###'), '') // Remove headers
        .replaceAll(RegExp(r'##'), '')  // Remove headers
        .replaceAll(RegExp(r'#'), '')   // Remove headers
        .replaceAll(RegExp(r'_'), '')   // Remove italics/underscore
        .replaceAll(RegExp(r'~'), '')   // Remove strikethrough
        .replaceAll(RegExp(r'\*'), '')  // Remove single asterisk
        .trim();
  }
}
