import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/screens/login_screen.dart';
import 'package:smart_farm/screens/orders_screen.dart';
import 'package:smart_farm/screens/locate_farm_screen.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/screens/scan_history_screen.dart';
import 'package:smart_farm/services/theme_service.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';
import 'package:smart_farm/services/translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String _name = '';
  String _fatherName = '';
  String _location = '';
  String _majorCrops = '';
  String _phone = '';
  String _profileImageUrl = '';
  Uint8List? _decodedProfileImage;

  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropsController = TextEditingController();
  final _phoneController = TextEditingController();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _locationController.dispose();
    _cropsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_uid.isEmpty) { setState(() => _isLoading = false); return; }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? '';
        _fatherName = data['fatherName'] ?? '';
        _location = data['location'] ?? '';
        _majorCrops = data['majorCrops'] ?? '';
        _phone = data['phone'] ?? '';
        _profileImageUrl = data['profileImageUrl'] ?? '';
      }
    } catch (_) {}
    _nameController.text = _name;
    _fatherNameController.text = _fatherName;
    _locationController.text = _location;
    _cropsController.text = _majorCrops;
    _phoneController.text = _phone;
    if (_profileImageUrl.startsWith('base64:')) {
      _decodedProfileImage = base64Decode(_profileImageUrl.substring(7));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_uid.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // Direct Firestore save using the base64 formatted string
      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'name': _nameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'location': _locationController.text.trim(),
        'majorCrops': _cropsController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileImageUrl': _profileImageUrl,
      }, SetOptions(merge: true));
      
      setState(() {
        _name = _nameController.text.trim();
        _fatherName = _fatherNameController.text.trim();
        _location = _locationController.text.trim();
        _majorCrops = _cropsController.text.trim();
        _phone = _phoneController.text.trim();
        _isEditing = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85, // Balanced compression for much better visual quality while keeping base64 size safe
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _profileImageUrl = 'base64:$base64String';
        _decodedProfileImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    if (_isLoading) return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, body: Center(child: FarmLoader(size: 80, color: Theme.of(context).primaryColor)));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Settings and Activity',
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showSettingsAndActivityMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Green banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickAvatar : null,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImageUrl.isEmpty
                            ? null
                            : (_profileImageUrl.startsWith('http')
                                ? NetworkImage(_profileImageUrl)
                                : _profileImageUrl.startsWith('base64:')
                                    ? (_decodedProfileImage != null ? MemoryImage(_decodedProfileImage!) : null)
                                    : FileImage(File(_profileImageUrl)) as ImageProvider),
                        child: _profileImageUrl.isEmpty
                            ? Icon(Icons.person, size: 48, color: Theme.of(context).primaryColor)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _name.isEmpty ? 'Welcome!' : 'Welcome, $_name',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _location.isEmpty ? 'No location set' : _location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Details card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField(Icons.person, TranslationService.translate('full_name'), _nameController, _isEditing, textColor),
                        const Divider(height: 24),
                        _buildField(Icons.family_restroom, TranslationService.translate('father_name'), _fatherNameController, _isEditing, textColor),
                        const Divider(height: 24),
                        _buildField(Icons.location_on, 'Address / Location', _locationController, _isEditing, textColor),
                        const Divider(height: 24),
                        _buildField(Icons.grass, 'Major Crops', _cropsController, _isEditing, textColor),
                        const Divider(height: 24),
                        _buildField(Icons.phone, 'Phone', _phoneController, _isEditing, textColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: FarmLoader.small())
                          : Icon(_isEditing ? Icons.save : Icons.edit),
                      label: Text(_isEditing ? 'Save Profile' : 'Edit Profile',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(context,
                              FastPageRoute(page: const LoginScreen()), (route) => false);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          FastPageRoute(page: const LocateFarmScreen()),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Locate My Farm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsAndActivityMenu(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final isDark = themeService.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Settings and Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.receipt_long, color: primaryColor),
              title: Text('My Orders', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, FastPageRoute(page: OrdersScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: Text('Scan History', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, FastPageRoute(page: const ScanHistoryScreen()));
              },
            ),
            const Divider(),
            StatefulBuilder(
              builder: (context, setModalState) {
                final currentIsDark = themeService.isDarkMode;
                return SwitchListTile(
                  title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                  secondary: Icon(currentIsDark ? Icons.dark_mode : Icons.light_mode, color: primaryColor),
                  value: currentIsDark,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    themeService.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    setModalState(() {}); // Update the switch in the modal
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, bool editing, Color? textColor) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: editing
              ? TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 15, color: textColor),
                  decoration: InputDecoration(
                    labelText: label,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(
                      controller.text.isEmpty ? 'Not set' : controller.text,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: controller.text.isEmpty ? Colors.grey : textColor),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
