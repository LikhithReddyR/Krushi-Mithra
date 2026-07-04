import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_farm/services/ai_scanner_service.dart';
import 'package:smart_farm/screens/scan_history_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiScannerService _aiService = AiScannerService();
  bool _isScanning = false;
  String? _scanResult;
  File? _scannedImage;

  Future<void> _scanImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _isScanning = true;
        _scannedImage = File(image.path);
        _scanResult = null;
      });

      // Analyze with Gemini
      final result = await _aiService.analyzeLeaf(_scannedImage!);
      final cleanedResult = _cleanText(result);

      // Save to history (don't block UI waiting for Firestore)
      _saveScanHistory(_scannedImage!, cleanedResult);

      if (mounted) {
        setState(() {
          _scanResult = cleanedResult;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _saveScanHistory(File imageFile, String result) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final scanId = const Uuid().v4();
      final now = DateTime.now();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(scanId)
          .set({
        'id': scanId,
        'type': 'leaf_scan',
        'result': result,
        'imagePath': imageFile.path,
        'timestamp': now,
        'source': 'mobile',
      });
    } catch (e) {
      debugPrint('Failed to save to history: $e');
    }
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '') 
        .replaceAll(RegExp(r'###'), '') 
        .replaceAll(RegExp(r'##'), '')  
        .replaceAll(RegExp(r'#'), '')   
        .replaceAll(RegExp(r'_'), '')   
        .replaceAll(RegExp(r'~'), '')   
        .replaceAll(RegExp(r'\*'), '')  
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Image.asset(
              'assets/images/farm_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),

          // Main UI
          SafeArea(
            child: _scanResult != null ? _buildResultView() : _buildScannerView(),
          ),
          
          // Back Button (Top Left)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  final canPop = Navigator.canPop(context);
                  if (!canPop) return const SizedBox.shrink();
                  
                  return GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),

          // History Button (Top Right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, FastPageRoute(page: const ScanHistoryScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          "Scan Crop",
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Check plant health instantly",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const Spacer(),
        
        // Custom Scanner Frame
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(280, 280),
                  painter: ScannerFramePainter(),
                ),
                if (_isScanning)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FarmLoader(size: 60, color: Color(0xFF28A745)),
                        const SizedBox(height: 16),
                        Text(TranslationService.translate('analyzing_leaf'), style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Instruction Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.black87.withOpacity(0.6), borderRadius: BorderRadius.circular(30)),
          child: const Text("Place leaf inside this frame", style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
        const Spacer(),

        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isScanning ? null : () => _scanImage(ImageSource.camera),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("Scan Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28A745),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isScanning ? null : () => _scanImage(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined, color: Colors.white),
                label: const Text("Upload Image", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Tips
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text("Use good lighting", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(width: 20),
                  Icon(Icons.center_focus_weak, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text("Avoid blurry images", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Analysis Result",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // The scanned image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
              child: _scannedImage != null 
                ? Image.file(_scannedImage!, fit: BoxFit.cover) 
                : const Center(child: Icon(Icons.image, color: Colors.white24, size: 64)),
            ),
          ),
          const SizedBox(height: 24),
          
          // Result Content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _scanResult ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          
          // Scan Another Button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _scanResult = null;
                _scannedImage = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Scan Another", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF28A745)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    const double cornerLength = 40.0;
    const double radius = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius))
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..arcToPoint(Offset(size.width, size.height - radius), radius: const Radius.circular(radius))
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
