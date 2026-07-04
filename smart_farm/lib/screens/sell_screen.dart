import 'package:flutter/material.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/services/mandi_service.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/widgets/farm_loader.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final MandiService _mandiService = MandiService();
  List<Map<String, dynamic>> _topCrops = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTopCrops();
  }

  Future<void> _loadTopCrops() async {
    setState(() => _isLoading = true);

    // Fetch top crops from live market data
    final results = await _mandiService.fetchMarketPrices(limit: 20);
    
    if (results.isNotEmpty) {
      // De-duplicate by commodity, keeping the entry with the highest modal price
      final Map<String, Map<String, dynamic>> uniqueCrops = {};
      for (final r in results) {
        final commodity = r['commodity'] as String;
        final price = double.tryParse(r['modal_price']?.toString() ?? '0') ?? 0;
        if (!uniqueCrops.containsKey(commodity) ||
            price > (double.tryParse(uniqueCrops[commodity]!['modal_price']?.toString() ?? '0') ?? 0)) {
          uniqueCrops[commodity] = r;
        }
      }
      _topCrops = uniqueCrops.values.toList();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Format price with Indian comma style
  String _formatPrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return "₹0";
    final price = double.tryParse(priceStr) ?? 0;
    if (price == 0) return "₹0";

    final parts = price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2).split('.');
    String intPart = parts[0];
    String result = '';

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

    if (parts.length > 1) return '₹$result.${parts[1]}';
    return '₹$result';
  }

  Color _getCropColor(String commodity) {
    final lower = commodity.toLowerCase();
    if (lower.contains('wheat') || lower.contains('kanak')) return Colors.amber.shade200;
    if (lower.contains('rice') || lower.contains('basmati') || lower.contains('paddy')) return Colors.brown.shade200;
    if (lower.contains('maize') || lower.contains('corn')) return Colors.yellow.shade300;
    if (lower.contains('tomato')) return Colors.red.shade200;
    if (lower.contains('onion')) return Colors.purple.shade200;
    if (lower.contains('potato')) return Colors.brown.shade300;
    if (lower.contains('turmeric')) return Colors.orange.shade200;
    if (lower.contains('arecanut')) return Colors.green.shade200;
    if (lower.contains('coconut')) return Colors.green.shade200;
    if (lower.contains('cotton')) return Colors.grey.shade300;
    if (lower.contains('sugar')) return Colors.pink.shade100;
    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Filter crops based on search
        final filteredCrops = _searchQuery.isEmpty
            ? _topCrops
            : _topCrops.where((c) =>
                (c['commodity'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (c['variety'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                const SizedBox(width: 8),
                Text('Krushi Mithra', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications, color: Theme.of(context).iconTheme.color, size: 20),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  },
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadTopCrops,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.translate('mandi_prices_title'),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineMedium?.color, height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              TranslationService.translate('mandi_prices_subtitle'),
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 8, color: Colors.green),
                                SizedBox(width: 4),
                                Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSearchBar(context),
                      const SizedBox(height: 16),
                      _buildFilters(context),
                      const SizedBox(height: 20),

                      if (_isLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: FarmLoader(size: 50, color: Color(0xFF28A745)),
                        ))
                      else if (filteredCrops.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? "No crops found for '$_searchQuery'"
                                      : "No market data available",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredCrops.asMap().entries.map((entry) {
                          final crop = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCropCard(
                              context,
                              name: "${crop['commodity']} (${crop['variety']})",
                              location: "${crop['market']}, ${crop['district']}",
                              price: _formatPrice(crop['modal_price']),
                              minPrice: _formatPrice(crop['min_price']),
                              maxPrice: _formatPrice(crop['max_price']),
                              arrivalDate: crop['arrival_date'] ?? '',
                              color: _getCropColor(crop['commodity']),
                              verified: entry.key == 0, // First (best) result is "verified"
                              state: crop['state'] ?? '',
                              rawData: crop,
                            ),
                          );
                        }),

                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMarketAnalysisBanner(context),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(TranslationService.translate('post_crop_coming_soon'))),
                        );
                      },
                      backgroundColor: isDark ? Theme.of(context).primaryColor : const Color(0xFF1E2124),
                      extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
                      elevation: 0,
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      label: Text(TranslationService.translate('post_your_crop'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
          hintText: TranslationService.translate('search_crops_hint'),
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
        ),
        onChanged: (val) {
          setState(() => _searchQuery = val);
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, TranslationService.translate('nearby'), true, icon: Icons.near_me),
          const SizedBox(width: 8),
          _buildChip(context, TranslationService.translate('best_price'), false, icon: Icons.trending_up),
          const SizedBox(width: 8),
          _buildChip(context, TranslationService.translate('more_filters'), false, icon: Icons.tune),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isSelected, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54), size: 16),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCropCard(
    BuildContext context, {
    required String name,
    required String location,
    required String price,
    required String minPrice,
    required String maxPrice,
    required String arrivalDate,
    required Color color,
    required bool verified,
    required String state,
    required Map<String, dynamic> rawData,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    rawData['commodity'] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
              if (verified)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.5) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(TranslationService.translate('verified'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
              // Date badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    arrivalDate,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ),
                    Text(
                      price,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).textTheme.bodySmall?.color, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(location, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Text(TranslationService.translate('per_quintal'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
                const SizedBox(height: 8),
                // Price range bar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _priceDetail("Min", minPrice, Colors.red.shade300),
                      Container(width: 1, height: 24, color: Colors.grey.shade300),
                      _priceDetail("Modal", price, const Color(0xFF28A745)),
                      Container(width: 1, height: 24, color: Colors.grey.shade300),
                      _priceDetail("Max", maxPrice, Colors.blue.shade400),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(TranslationService.translate('sell_flow_coming_soon'))),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                        label: Text(TranslationService.translate('sell'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.bookmark_border, size: 20),
                        onPressed: () {
                          _mandiService.saveRate(rawData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Saved ${rawData['commodity']} rate!")),
                          );
                        },
                        tooltip: "Save Rate",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.call, color: Theme.of(context).iconTheme.color, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(TranslationService.translate('call_feature_coming_soon'))),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _priceDetail(String label, String price, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(price, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMarketAnalysisBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).primaryColor.withOpacity(0.1) : const Color(0xFFFBEBE4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE5C0B3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.bar_chart, color: isDark ? Colors.white70 : Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TranslationService.translate('market_analysis'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(
                  TranslationService.translate('market_analysis_desc'),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
