import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MandiService {
  // Cache keys
  static const String _pricesCacheKey = 'cached_market_prices';
  static const String _pricesCacheTimeKey = 'cached_market_prices_time';
  static const String _livestockCacheKey = 'cached_livestock_prices';
  static const String _livestockCacheTimeKey = 'cached_livestock_prices_time';
  static const Duration _cacheDuration = Duration(hours: 1); // Refresh every hour

  MandiService();

  Future<void> clearLivestockCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_livestockCacheKey);
      await prefs.remove(_livestockCacheTimeKey);
      print("MandiService: Livestock cache cleared");
    } catch (e) {
      print("MandiService: Error clearing cache: $e");
    }
  }

  // ---------- CACHE HELPERS ----------

  Future<void> _savePricesToCache(String key, String timeKey, List<Map<String, dynamic>> prices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(prices));
      await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print("MandiService: Cache save error: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> _loadPricesFromCache(String key, String timeKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTime = prefs.getInt(timeKey);
      final cachedData = prefs.getString(key);
      
      if (cachedTime != null && cachedData != null) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedTime);
        final now = DateTime.now();
        if (now.difference(cachedAt) < _cacheDuration) {
          return List<Map<String, dynamic>>.from(
            (json.decode(cachedData) as List).map((e) => Map<String, dynamic>.from(e))
          );
        }
      }
    } catch (e) {
      print("MandiService: Cache load error: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> _loadStaleCacheAsFallback(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(key);
      if (cachedData != null) {
        return List<Map<String, dynamic>>.from(
          (json.decode(cachedData) as List).map((e) => Map<String, dynamic>.from(e))
        );
      }
    } catch (_) {}
    return null;
  }

  // ---------- MARKET PRICES ----------

  Future<List<Map<String, dynamic>>> fetchMarketPrices({
    int limit = 50,
    String? commodity,
    String? district,
    bool forceRefresh = false,
  }) async {
    print("MandiService: fetchMarketPrices from Firestore");

    if (!forceRefresh) {
      final cacheKey = '${_pricesCacheKey}_${commodity ?? "all"}_${district ?? "all"}';
      final cacheTimeKey = '${_pricesCacheTimeKey}_${commodity ?? "all"}_${district ?? "all"}';
      final cached = await _loadPricesFromCache(cacheKey, cacheTimeKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      Query query = FirebaseFirestore.instance.collection('mandi_prices').limit(limit);

      if (commodity != null && commodity.isNotEmpty) {
        // commodity search is exact based on scraped formats
        query = query.where('commodity', isEqualTo: commodity[0].toUpperCase() + commodity.substring(1).toLowerCase());
      } else if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        
        // Caching
        final cacheKey = '${_pricesCacheKey}_${commodity ?? "all"}_${district ?? "all"}';
        final cacheTimeKey = '${_pricesCacheTimeKey}_${commodity ?? "all"}_${district ?? "all"}';
        await _savePricesToCache(cacheKey, cacheTimeKey, results);

        return results;
      }
    } catch (e) {
      print("MandiService: Error fetching market prices: $e");
    }

    // Try stale cache if Firestore fails or empty
    final cacheKey = '${_pricesCacheKey}_${commodity ?? "all"}_${district ?? "all"}';
    final stale = await _loadStaleCacheAsFallback(cacheKey);
    if (stale != null && stale.isNotEmpty) return stale;

    return [];
  }

  // ---------- HISTORY (Migrated to use mandi_prices as well) ----------

  Future<List<Map<String, dynamic>>> getPriceHistory(String commodity, {int days = 7}) async {
    try {
      // Historical trends aren't fully baked in the new scraper yet, 
      // but returning current prices to avoid runtime errors gracefully.
      final snapshot = await FirebaseFirestore.instance
          .collection('mandi_prices')
          .where('commodity', isEqualTo: commodity)
          .limit(days * 5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          "commodity": data['commodity'] ?? "",
          "market": data['market'] ?? "",
          "modal_price": data['modal_price']?.toString() ?? "0",
          "arrival_date": data['arrival_date'] ?? "",
          "savedAt": FieldValue.serverTimestamp(),
        };
      }).toList();
    } catch (e) {
      print("MandiService: Error fetching price history: $e");
      return [];
    }
  }

  Future<double?> getPriceChangePercent(String commodity) async {
      return null; // History isn't full yet for % calculation with new scraped data
  }

  // ---------- MARKETS IN DISTRICT ----------

  Future<List<String>> fetchMarketsInDistrict(String district) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mandi_prices')
          .where('district', isEqualTo: district)
          .get();
      final markets = snapshot.docs
          .map((doc) => doc.data()['market'] as String?)
          .where((m) => m != null)
          .cast<String>()
          .toSet()
          .toList();
      return markets;
    } catch (e) {
      print("MandiService: Error in fetchMarketsInDistrict: $e");
      return [];
    }
  }

  // ---------- MARKETPLACE (FIREBASE) ----------

  Stream<QuerySnapshot> getMarketplaceListings() {
    return FirebaseFirestore.instance
        .collection('mandi_listings')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addListing({
    required String commodity,
    required String variety,
    required String quantity,
    required double price,
    required String location,
    required String phone,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userName = user.displayName ?? 'Anonymous Farmer';
    String fatherName = '';

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        if (data['name'] != null && (data['name'] as String).isNotEmpty) {
          userName = data['name'];
        }
        fatherName = data['fatherName'] ?? '';
      }
    } catch (e) {
      print("MandiService: Error fetching profile for listing: $e");
    }

    await FirebaseFirestore.instance.collection('mandi_listings').add({
      'userId': user.uid,
      'userName': userName,
      'fatherName': fatherName,
      'commodity': commodity,
      'variety': variety,
      'quantity': quantity,
      'price': price,
      'location': location,
      'phone': phone,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteListing(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('mandi_listings').doc(docId).delete();
    } catch (e) {
      print("MandiService: Error deleting listing: $e");
    }
  }

  // ---------- LIVESTOCK PRICES ----------

  Future<List<Map<String, dynamic>>> fetchLivestockPrices() async {
    print("MandiService: fetchLivestockPrices from Firestore");

    final cached = await _loadPricesFromCache(_livestockCacheKey, _livestockCacheTimeKey);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final snapshot = await FirebaseFirestore.instance.collection('livestock_prices').get();
      if (snapshot.docs.isNotEmpty) {
        final results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        await _savePricesToCache(_livestockCacheKey, _livestockCacheTimeKey, results);
        return results;
      }
    } catch (e) {
      print("MandiService: Error fetching Firestore livestock prices: $e");
    }

    final stale = await _loadStaleCacheAsFallback(_livestockCacheKey);
    if (stale != null && stale.isNotEmpty) return stale;

    return [];
  }

  // ---------- SAVED RATES (USER'S WATCHLIST) ----------

  Future<void> saveRate(Map<String, dynamic> priceData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_rates')
        .add({
      ...priceData,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSavedRate(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_rates')
        .doc(docId)
        .delete();
  }

  Stream<QuerySnapshot> getSavedRates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_rates')
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> refreshSavedRatesWithCurrentPrices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final savedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_rates')
        .get();

    List<Map<String, dynamic>> updatedRates = [];

    for (final doc in savedSnapshot.docs) {
      final data = doc.data();
      final commodity = data['commodity'] as String?;
      final district = data['district'] as String?;

      if (commodity != null) {
        final currentPrices = await fetchMarketPrices(
          commodity: commodity,
          district: district,
          limit: 5,
          forceRefresh: true,
        );

        if (currentPrices.isNotEmpty) {
          final current = currentPrices.first;
          final oldPrice = double.tryParse(data['modal_price']?.toString() ?? '0') ?? 0;
          final newPrice = double.tryParse(current['modal_price']?.toString() ?? '0') ?? 0;
          final changePercent = oldPrice > 0 ? ((newPrice - oldPrice) / oldPrice) * 100 : 0.0;

          updatedRates.add({
            'docId': doc.id,
            ...current,
            'old_price': data['modal_price']?.toString() ?? '0',
            'price_change_percent': changePercent.toStringAsFixed(2),
            'savedAt': data['savedAt'],
          });

          await doc.reference.update({
            'modal_price': current['modal_price'],
            'min_price': current['min_price'],
            'max_price': current['max_price'],
            'arrival_date': current['arrival_date'],
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          updatedRates.add({
            'docId': doc.id,
            ...data,
            'price_change_percent': '0.00',
          });
        }
      }
    }
    return updatedRates;
  }
}
