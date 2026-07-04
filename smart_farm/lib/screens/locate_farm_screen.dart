import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:smart_farm/services/translation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocateFarmScreen extends StatefulWidget {
  const LocateFarmScreen({super.key});

  @override
  State<LocateFarmScreen> createState() => _LocateFarmScreenState();
}

class _LocateFarmScreenState extends State<LocateFarmScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _polygonPoints = [];
  bool _isSatellite = true;
  double _areaSqMeters = 0.0;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  bool _isSaving = false;
  bool _isFetchingFarm = true;

  @override
  void initState() {
    super.initState();
    _loadFarmLocation().then((_) => _getCurrentLocation());
  }

  Future<void> _loadFarmLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isFetchingFarm = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!['farmLocation'] != null) {
        final List<dynamic> locs = doc.data()!['farmLocation'];
        final points = locs.map((e) => LatLng(e['lat'] as double, e['lng'] as double)).toList();
        setState(() {
          _polygonPoints = points;
          _calculateArea();
        });
        if (points.isNotEmpty) {
           _mapController.move(points.first, 16.0);
        }
      }
    } catch (e) {
      debugPrint('Error loading farm: $e');
    }
    if (mounted) {
      setState(() => _isFetchingFarm = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    // Attempt to get high accuracy position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      // Move map to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16.0,
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _polygonPoints.add(latlng);
      _calculateArea();
    });
  }

  void _calculateArea() {
    if (_polygonPoints.length < 3) {
      _areaSqMeters = 0.0;
      return;
    }
    _areaSqMeters = _SphericalUtil.computeArea(_polygonPoints);
  }

  void _clearMap() {
    setState(() {
      _polygonPoints.clear();
      _areaSqMeters = 0.0;
    });
  }

  Future<void> _saveLocation() async {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a complete boundary (at least 3 points).')),
      );
      return;
    }
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save your farm.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final farmData = _polygonPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'farmLocation': farmData,
        'farmAreaSqMeters': _areaSqMeters,
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm location saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save farm location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Locate My Farm V1', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Stack(
        children: [
          // Flutter Map Full Screen
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  // Default to geographic center of India if location is disabled
                  : const LatLng(20.5937, 78.9629),
              initialZoom: 15.0,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : (isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                userAgentPackageName: 'com.example.smart_farm',
              ),
              if (_polygonPoints.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: Colors.green.withOpacity(0.3),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2.0,
                      isFilled: true,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Plot tapped points
                  ..._polygonPoints.map((point) => Marker(
                        point: point,
                        width: 12,
                        height: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                        ),
                      )),
                  // Current user location
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Map Controls overlay (top right)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Location Button
                FloatingActionButton(
                  heroTag: 'location_btn',
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.move(LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 16.0);
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  child: Icon(Icons.my_location, color: Theme.of(context).iconTheme.color),
                ),
                const SizedBox(height: 12),
                // Satellite Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Satellite', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Switch(
                          value: _isSatellite,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            setState(() {
                              _isSatellite = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 10, spreadRadius: 2)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Coordinates Display
                    if (_polygonPoints.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Theme.of(context).iconTheme.color, size: 20),
                          const SizedBox(width: 8),
                          Text('Latitude: ${_polygonPoints.first.latitude.toStringAsFixed(4)} N', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Theme.of(context).iconTheme.color, size: 20),
                          const SizedBox(width: 8),
                          Text('Longitude: ${_polygonPoints.first.longitude.toStringAsFixed(4)} E', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ],
                      ),
                    ] else ...[
                      Text('Tap on the map to start drawing your farm boundary.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    
                    // Area Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047), // Green
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Farm Area: ${(_areaSqMeters * 0.000247105).toStringAsFixed(1)} Acres',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_areaSqMeters / 10000).toStringAsFixed(2)} Hectares | ${_areaSqMeters.toStringAsFixed(0)} Sq. Meters',
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearMap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.redAccent : const Color(0xFF5D4037),
                              side: BorderSide(color: isDark ? Colors.redAccent : const Color(0xFF5D4037)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Clear Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334E35), // Dark green
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Save Farm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility for calculating Area of a spherical polygon
class _SphericalUtil {
  static double computeArea(List<LatLng> path) {
    return computeSignedArea(path).abs();
  }

  static double computeSignedArea(List<LatLng> path) {
    if (path.length < 3) {
      return 0.0;
    }
    double total = 0.0;
    final int size = path.length;
    final LatLng prev = path[size - 1];
    double prevTanLat = math.tan((math.pi / 2 - _radians(prev.latitude)) / 2);
    double prevLng = _radians(prev.longitude);

    for (int i = 0; i < size; i++) {
      final LatLng point = path[i];
      final double tanLat = math.tan((math.pi / 2 - _radians(point.latitude)) / 2);
      final double lng = _radians(point.longitude);
      total += _polarTriangleArea(tanLat, lng, prevTanLat, prevLng);
      prevTanLat = tanLat;
      prevLng = lng;
    }
    return total * (6371009.0 * 6371009.0);
  }

  static double _polarTriangleArea(double tan1, double lng1, double tan2, double lng2) {
    final double deltaLng = lng1 - lng2;
    final double t = tan1 * tan2;
    return 2 * math.atan2(t * math.sin(deltaLng), 1 + t * math.cos(deltaLng));
  }
  
  static double _radians(double degree) => degree * math.pi / 180.0;
}
