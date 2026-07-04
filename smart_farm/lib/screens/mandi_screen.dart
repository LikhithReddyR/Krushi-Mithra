import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_farm/services/mandi_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MandiScreen extends StatefulWidget {
  final int initialIndex;
  const MandiScreen({super.key, this.initialIndex = 0});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MandiService _mandiService = MandiService();
  String _searchQuery = "";
  String? _currentDistrict;
  List<Map<String, dynamic>> _prices = [];
  List<Map<String, dynamic>> _livestockPrices = [];
  List<Map<String, dynamic>> _savedRates = [];
  List<String> _localMarkets = [];
  bool _isLoadingPrices = true;
  bool _isLoadingLivestock = false;
  bool _isLoadingLocalMarkets = false;
  bool _isLoadingSavedRates = false;
  DateTime? _lastFetchedAt;
  
  // Price change cache
  final Map<String, double?> _priceChanges = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    // Load preliminary data immediately so user isn't stuck waiting 
    _loadPrices();
    _loadLivestockPrices();
    _loadSavedRates();

    // Fetch location in background and update only if a district is found
    _initLocation().then((_) {
      if (_currentDistrict != null && mounted) {
        _loadPrices(forceRefresh: true);
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          setState(() {
            _currentDistrict = placemarks.first.subAdministrativeArea ?? placemarks.first.locality;
          });
          print("MandiScreen: Detected District: $_currentDistrict");
          _loadLocalMarkets();
        }
      }
    } catch (e) {
      print("MandiScreen: Error getting location: $e");
    }
  }

  Future<void> _loadLocalMarkets() async {
    if (_currentDistrict == null) return;
    setState(() => _isLoadingLocalMarkets = true);
    final markets = await _mandiService.fetchMarketsInDistrict(_currentDistrict!);
    if (mounted) {
      setState(() {
        _localMarkets = markets;
        _isLoadingLocalMarkets = false;
      });
    }
  }

  Future<void> _loadLivestockPrices() async {
    setState(() => _isLoadingLivestock = true);
    // Clear old cache to ensure fresh data with correct unit conversion
    await _mandiService.clearLivestockCache();
    final results = await _mandiService.fetchLivestockPrices();
    if (mounted) {
      setState(() {
        _livestockPrices = results;
        _isLoadingLivestock = false;
      });
    }
  }

  Future<void> _loadSavedRates() async {
    setState(() => _isLoadingSavedRates = true);
    final results = await _mandiService.refreshSavedRatesWithCurrentPrices();
    if (mounted) {
      setState(() {
        _savedRates = results;
        _isLoadingSavedRates = false;
      });
    }
  }

  Future<void> _loadPrices({bool forceRefresh = false}) async {
    setState(() => _isLoadingPrices = true);
    final results = await _mandiService.fetchMarketPrices(
      commodity: _searchQuery.isNotEmpty ? _searchQuery : null,
      district: _currentDistrict,
      forceRefresh: forceRefresh,
    );

    // Load price changes for each unique commodity
    final commodities = results.map((r) => r['commodity'] as String).toSet();
    for (final c in commodities) {
      if (!_priceChanges.containsKey(c)) {
        _priceChanges[c] = await _mandiService.getPriceChangePercent(c);
      }
    }

    if (mounted) {
      setState(() {
        _prices = results;
        _isLoadingPrices = false;
        _lastFetchedAt = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Format price with proper Indian currency formatting (e.g. ₹4,200)
  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return "₹0";
    final price = double.tryParse(priceStr) ?? 0;
    if (price == 0) return "₹0";

    // Format with commas (Indian style)
    final parts = price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2).split('.');
    String intPart = parts[0];
    String result = '';
    
    // Indian numbering: last 3 digits, then groups of 2
    if (intPart.length > 3) {
      result = intPart.substring(intPart.length - 3);
      intPart = intPart.substring(0, intPart.length - 3);
      while (intPart.length > 2) {
        result = '${intPart.substring(intPart.length - 2)},$result';
        intPart = intPart.substring(0, intPart.length - 2);
      }
      result = '$intPart,$result';
    } else {
      result = intPart;
    }

    if (parts.length > 1) {
      return '₹$result.${parts[1]}';
    }
    return '₹$result';
  }

  /// Get trend icon and color for a price change
  Widget _buildTrendIndicator(double? changePercent) {
    if (changePercent == null) {
      return const SizedBox.shrink();
    }
    
    final isUp = changePercent > 0;
    final isFlat = changePercent.abs() < 0.5;
    
    if (isFlat) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_flat, size: 14, color: Colors.grey),
            SizedBox(width: 2),
            Text("Stable", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isUp ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: isUp ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            "${isUp ? '+' : ''}${changePercent.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 10,
              color: isUp ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Krushi Mandi'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: TranslationService.translate('market_prices') ?? 'Market Prices'),
            const Tab(text: 'Saved Rates'),
            const Tab(text: 'Livestock'),
            Tab(text: TranslationService.translate('marketplace') ?? 'Market Place'),
            Tab(text: TranslationService.translate('markets') ?? 'Markets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPricesTab(),
          _buildSavedRatesTab(),
          _buildLivestockTab(),
          _buildMarketplaceTab(),
          _buildMarketsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 3
          ? FloatingActionButton.extended(
              onPressed: () => _showAddListingDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Sell Crop"),
            )
          : null,
    );
  }

  Widget _buildPricesTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search Commodity (e.g. Rice, Tomato)",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  onSubmitted: (val) {
                    setState(() => _searchQuery = val);
                    _loadPrices(forceRefresh: true);
                  },
                ),
              ),
              if (_currentDistrict != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.location_off_outlined, color: Colors.red),
                  onPressed: () {
                    setState(() => _currentDistrict = null);
                    _loadPrices(forceRefresh: true);
                  },
                  tooltip: "Clear Location Filter",
                ),
              ],
            ],
          ),
        ),

        // Location + last updated info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
          child: Row(
            children: [
              if (_currentDistrict != null) ...[
                const Icon(Icons.location_on, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Showing prices for: $_currentDistrict",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
              if (_lastFetchedAt != null)
                Text(
                  "Updated ${_formatTimeAgo(_lastFetchedAt!)}",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),

        // Prices list
        Expanded(
          child: _isLoadingPrices
              ? const Center(child: FarmLoader(size: 50, color: Color(0xFF28A745)))
              : _prices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No market prices available.\nTry searching for a specific commodity.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _loadPrices(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadPrices(forceRefresh: true),
                      child: ListView.builder(
                        itemCount: _prices.length,
                        itemBuilder: (context, index) {
                          final p = _prices[index];
                          final commodity = p['commodity'] ?? '';
                          final change = _priceChanges[commodity];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Commodity icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _getCommodityColor(commodity).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCommodityIcon(commodity),
                                      color: _getCommodityColor(commodity),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Commodity info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${p['commodity']} - ${p['variety']}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            _buildTrendIndicator(change),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${p['market']}, ${p['district']}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Date: ${p['arrival_date']}",
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Prices
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatPrice(p['modal_price']),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF28A745),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${_formatPrice(p['min_price'])} - ${_formatPrice(p['max_price'])}",
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                      ),
                                      Text(
                                        "per ${p['unit'] ?? 'Quintal'}",
                                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                    ],
                                  ),

                                  // Save button
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark_border, size: 20),
                                    color: Colors.grey,
                                    onPressed: () => _saveRate(p),
                                    tooltip: "Save Rate",
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSavedRatesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.bookmark, color: Color(0xFF28A745)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Your Saved Rates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: _loadSavedRates,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Track your important commodity prices. Rates update automatically from current market data.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoadingSavedRates
              ? const Center(child: FarmLoader(size: 40, color: Color(0xFF28A745)))
              : _savedRates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            "No saved rates yet.\nSave rates from Market Prices tab to track them here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSavedRates,
                      child: ListView.builder(
                        itemCount: _savedRates.length,
                        itemBuilder: (context, index) {
                          final r = _savedRates[index];
                          final changeStr = r['price_change_percent']?.toString() ?? '0';
                          final change = double.tryParse(changeStr) ?? 0;
                          final oldPrice = r['old_price']?.toString();

                          return Dismissible(
                            key: Key(r['docId'] ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red.shade100,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.red),
                            ),
                            onDismissed: (_) {
                              if (r['docId'] != null) {
                                _mandiService.removeSavedRate(r['docId']);
                              }
                              setState(() => _savedRates.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Rate removed")),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: change > 0
                                      ? Colors.green.withOpacity(0.3)
                                      : change < 0
                                          ? Colors.red.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getCommodityColor(r['commodity'] ?? '').withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getCommodityIcon(r['commodity'] ?? ''),
                                            color: _getCommodityColor(r['commodity'] ?? ''),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${r['commodity']} - ${r['variety']}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              Text(
                                                "${r['market']}, ${r['district']}",
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              _formatPrice(r['modal_price']),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF28A745),
                                              ),
                                            ),
                                            if (oldPrice != null && oldPrice != r['modal_price'])
                                              Text(
                                                "was ${_formatPrice(oldPrice)}",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildTrendIndicator(change),
                                        const Spacer(),
                                        Text(
                                          "${_formatPrice(r['min_price'])} - ${_formatPrice(r['max_price'])} per ${r['unit'] ?? 'Quintal'}",
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildLivestockTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Live Livestock & Poultry Rates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
        ),
        if (_livestockPrices.isEmpty && !_isLoadingLivestock)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  "No real-time livestock prices available right now.\n\nPlease check reliable sources like AgMarkNet, e-NAM, or your local mandi websites for the latest accurate rates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadLivestockPrices,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry Fetching"),
                ),
              ],
            ),
          ),
        Expanded(
          child: _isLoadingLivestock
              ? const Center(child: FarmLoader(size: 50, color: Colors.brown))
              : RefreshIndicator(
                  onRefresh: _loadLivestockPrices,
                  child: ListView.builder(
                    itemCount: _livestockPrices.length,
                    itemBuilder: (context, index) {
                      final p = _livestockPrices[index];
                      final commodity = (p['commodity'] ?? '').toString().toLowerCase();
                      final isEgg = commodity.contains('egg');
                      final isHen = commodity.contains('hen') || commodity.contains('chicken');
                      final isFish = commodity.contains('fish');
                      final isMilk = commodity.contains('milk');
                      final isGoatOrSheep = commodity.contains('goat') || commodity.contains('sheep');
                      
                      IconData icon;
                      Color accentColor;
                      if (isEgg) {
                        icon = Icons.egg_outlined;
                        accentColor = Colors.orange;
                      } else if (isHen) {
                        icon = Icons.pets;
                        accentColor = Colors.red.shade400;
                      } else if (isFish) {
                        icon = Icons.water;
                        accentColor = Colors.blue;
                      } else if (isMilk) {
                        icon = Icons.water_drop_outlined;
                        accentColor = Colors.lightBlue;
                      } else if (isGoatOrSheep) {
                        icon = Icons.grass;
                        accentColor = Colors.green.shade700;
                      } else {
                        icon = Icons.pets;
                        accentColor = Colors.brown;
                      }

                      final minPrice = p['min_price']?.toString();
                      final maxPrice = p['max_price']?.toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isEgg
                              ? const BorderSide(color: Colors.orange, width: 1.5)
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: accentColor.withOpacity(0.1),
                                child: Icon(icon, color: accentColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${p['commodity']} - ${p['variety']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${p['market']}, ${p['district']}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Updated: ${p['arrival_date']}",
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatPrice(p['price']?.toString()),
                                    style: TextStyle(fontSize: 18, color: accentColor, fontWeight: FontWeight.bold),
                                  ),
                                  Text("per ${p['unit']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  if (minPrice != null && maxPrice != null)
                                    Text(
                                      "${_formatPrice(minPrice)} - ${_formatPrice(maxPrice)}",
                                      style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _mandiService.getMarketplaceListings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: FarmLoader(size: 40, color: Colors.blue));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No listings yet. Be the first to sell!"));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isSell = data['type'] == 'sell';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isSell ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(isSell ? "FOR SALE" : "BUYING", style: TextStyle(color: isSell ? Colors.green : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Text(data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 10) : "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        if (data['userId'] == FirebaseAuth.instance.currentUser?.uid)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Listing"),
                                  content: const Text("Are you sure you want to delete your crop listing?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () {
                                        _mandiService.deleteListing(doc.id);
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Listing deleted")));
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("${data['commodity']} (${data['variety']})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Qty: ${data['quantity']} | Price: ${_formatPrice(data['price']?.toString())}", style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(data['location'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Farmer: ${data['userName']}${data['fatherName'] != null && (data['fatherName'] as String).isNotEmpty ? " (S/O: ${data['fatherName']})" : ""}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse("tel:${data['phone']}")),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMarketsTab() {
    final majorMarkets = [
      {'name': 'Bangalore APMC', 'city': 'Yeshwanthpur, Bangalore', 'lat': '13.0292', 'lng': '77.5409'},
      {'name': 'Mysore APMC', 'city': 'Mysuru', 'lat': '12.3117', 'lng': '76.6436'},
      {'name': 'Shimoga APMC', 'city': 'Shivamogga', 'lat': '13.9299', 'lng': '75.5681'},
      {'name': 'Hubli APMC', 'city': 'Hubballi', 'lat': '15.3647', 'lng': '75.1240'},
    ];

    return ListView(
      children: [
        if (_currentDistrict != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Markets in $_currentDistrict", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          if (_isLoadingLocalMarkets)
            const Center(child: FarmLoader(size: 30, color: Colors.green))
          else if (_localMarkets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("No specific markets found in your district from recent reports."),
            )
          else
            ..._localMarkets.map((m) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.location_on, color: Colors.green)),
                title: Text(m),
                subtitle: Text("District: $_currentDistrict"),
                trailing: IconButton(
                  icon: const Icon(Icons.navigation, color: Colors.blue),
                  onPressed: () {
                    final query = Uri.encodeComponent("APMC $m $_currentDistrict");
                    launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=$query"));
                  },
                ),
              ),
            )),
          const Divider(height: 32, thickness: 2),
        ],
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Major Markets (Karnataka)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...majorMarkets.map((m) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.store, color: Colors.green)),
            title: Text(m['name']!),
            subtitle: Text(m['city']!),
            trailing: IconButton(
              icon: const Icon(Icons.navigation, color: Colors.blue),
              onPressed: () {
                launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${m['lat']},${m['lng']}"));
              },
            ),
          ),
        )),
      ],
    );
  }

  // ---------- HELPERS ----------

  void _saveRate(Map<String, dynamic> priceData) async {
    try {
      await _mandiService.saveRate(priceData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved ${priceData['commodity']} rate!"),
            action: SnackBarAction(
              label: "View",
              onPressed: () => _tabController.animateTo(1), // Switch to Saved Rates tab
            ),
          ),
        );
        _loadSavedRates(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to save rates")),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  IconData _getCommodityIcon(String commodity) {
    final lower = commodity.toLowerCase();
    if (lower.contains('rice') || lower.contains('paddy')) return Icons.rice_bowl;
    if (lower.contains('wheat')) return Icons.grass;
    if (lower.contains('tomato')) return Icons.local_florist;
    if (lower.contains('onion')) return Icons.circle;
    if (lower.contains('potato')) return Icons.breakfast_dining;
    if (lower.contains('egg')) return Icons.egg;
    if (lower.contains('maize') || lower.contains('corn')) return Icons.grain;
    if (lower.contains('turmeric') || lower.contains('chilli')) return Icons.local_fire_department;
    if (lower.contains('arecanut') || lower.contains('coconut')) return Icons.park;
    if (lower.contains('sugar')) return Icons.cake;
    if (lower.contains('cotton')) return Icons.cloud;
    if (lower.contains('banana') || lower.contains('mango') || lower.contains('apple')) return Icons.apple;
    return Icons.eco;
  }

  Color _getCommodityColor(String commodity) {
    final lower = commodity.toLowerCase();
    if (lower.contains('rice') || lower.contains('paddy')) return Colors.brown;
    if (lower.contains('wheat')) return Colors.amber;
    if (lower.contains('tomato')) return Colors.red;
    if (lower.contains('onion')) return Colors.purple;
    if (lower.contains('potato')) return Colors.brown;
    if (lower.contains('egg')) return Colors.orange;
    if (lower.contains('maize') || lower.contains('corn')) return Colors.yellow.shade800;
    if (lower.contains('turmeric')) return Colors.orange.shade800;
    if (lower.contains('chilli')) return Colors.red.shade800;
    if (lower.contains('arecanut')) return Colors.green.shade800;
    if (lower.contains('coconut')) return Colors.green;
    if (lower.contains('sugar')) return Colors.pink;
    if (lower.contains('cotton')) return Colors.blueGrey;
    return const Color(0xFF28A745);
  }

  void _showAddListingDialog() {
    final formKey = GlobalKey<FormState>();
    String commodity = '', variety = '', quantity = '', location = '', phone = '', type = 'sell';
    double price = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Post Crop Listing", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [DropdownMenuItem(value: 'sell', child: Text("I want to Sell")), DropdownMenuItem(value: 'buy', child: Text("I want to Buy"))],
                onChanged: (val) => type = val!,
              ),
              TextFormField(decoration: const InputDecoration(labelText: "Commodity (e.g. Paddy)"), onSaved: (val) => commodity = val!),
              TextFormField(decoration: const InputDecoration(labelText: "Variety (e.g. Sona Masuri)"), onSaved: (val) => variety = val!),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: "Quantity (e.g. 50 Quintals)"), onSaved: (val) => quantity = val!)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: "Price per Unit"), keyboardType: TextInputType.number, onSaved: (val) => price = double.tryParse(val!) ?? 0)),
                ],
              ),
              TextFormField(decoration: const InputDecoration(labelText: "Location (Village/Taluk)"), onSaved: (val) => location = val!),
              TextFormField(decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone, onSaved: (val) => phone = val!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.pop(context);
                    await _mandiService.addListing(commodity: commodity, variety: variety, quantity: quantity, price: price, location: location, phone: phone, type: type);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Listing posted successfully!")));
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF28A745), foregroundColor: Colors.white),
                child: const Text("POST LISTING"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
