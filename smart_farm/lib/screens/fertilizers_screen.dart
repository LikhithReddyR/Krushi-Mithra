import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/screens/product_detail_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // to get Product model

class FertilizersScreen extends StatefulWidget {
  const FertilizersScreen({super.key});

  @override
  State<FertilizersScreen> createState() => _FertilizersScreenState();
}

class _FertilizersScreenState extends State<FertilizersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('fertilizers').get();
        if (snapshot.docs.isEmpty) {
          // Seed if empty
          await _seedDatabase();
          final newSnapshot = await _firestore.collection('fertilizers').get();
          if (mounted) {
            setState(() {
              _products = newSnapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _products = snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
              _isLoading = false;
            });
          }
      }
    } catch (e) {
      debugPrint("Error fetching fertilizers from Firebase: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _seedDatabase() async {
    List<Product> initialProducts = [
        Product(
          name: 'Saaf Fertilizer',
          category: 'Fungicide',
          image: 'assets/images/saaf_fertilizer.png',
          currentPrice: 120.0,
          originalPrice: 170.0,
          discountPercent: 29,
          likes: 245,
          quantity: '250 g',
          brand: 'Saafilizer',
          description: 'Carbendazim 12% + Mancozeb 63% WP. Systemic and contact fungicide.',
          suitableCrops: 'All crops',
        ),
        Product(
          name: 'Azospirillum',
          category: 'Bio Fertilizer',
          image: 'assets/images/azospirillum_fertilizer.png',
          currentPrice: 180.0,
          originalPrice: 230.0,
          discountPercent: 21,
          likes: 188,
          quantity: '500 ml',
          brand: 'BioAgri',
          description: 'Nitrogen fixing bio fertilizer for soil application.',
          suitableCrops: 'Paddy, Wheat, Maize',
        ),
        Product(
          name: 'Saaf Packet',
          category: 'Fungicide',
          image: 'assets/images/saaf_fertilizer_packet.png',
          currentPrice: 65.0,
          originalPrice: 90.0,
          discountPercent: 27,
          likes: 156,
          quantity: '100 g',
          brand: 'Saaf',
          description: 'Small pack of Carbendazim + Mancozeb.',
          suitableCrops: 'Flowers, Vegetables',
        ),
        Product(
            name: 'Bio Compost',
            category: 'Organic Fertilizer',
            image: 'assets/images/neem_oil_spray.png', // Fallback image
            currentPrice: 200.0,
            originalPrice: 250.0,
            discountPercent: 20,
            likes: 312,
            quantity: '1 Kg',
            brand: 'SKV Organics',
            description: '100% Organic Manure with no chemicals.',
            suitableCrops: 'All plants',
        ),
    ];
    
    WriteBatch batch = _firestore.batch();
    for (var prod in initialProducts) {
      DocumentReference docRef = _firestore.collection('fertilizers').doc();
      batch.set(docRef, prod.toMap());
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(
                child: _isLoading 
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                    : _buildProductGrid(),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Fertilizers', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: ListenableBuilder(
                listenable: CartService.instance,
                builder: (context, child) {
                  final totalItems = CartService.instance.totalItems;
                  if (totalItems == 0) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                    child: Text('$totalItems', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeContext = context;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(themeContext, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(themeContext).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: product.image.startsWith('http')
                          ? Image.network(
                              product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                            )
                          : product.image.startsWith('base64:')
                              ? Image.memory(
                                  product.decodedImage ?? (() {
                                    final bytes = base64Decode(product.image.substring(7));
                                    product.setDecodedImage(bytes);
                                    return bytes;
                                  })(),
                                  fit: BoxFit.contain,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                                )
                              : Image.asset(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                                ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(themeContext).textTheme.bodyLarge?.color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.brand} • ${product.quantity}',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 10, color: isDark ? Theme.of(themeContext).primaryColor : Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₹${product.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(themeContext).textTheme.bodyLarge?.color)),
                      const SizedBox(width: 4),
                      Text('₹${product.originalPrice.toInt()}', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 10, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          CartService.instance.addToCart(product);
                          ScaffoldMessenger.of(themeContext).hideCurrentSnackBar();
                          ScaffoldMessenger.of(themeContext).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Theme.of(themeContext).primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'VIEW',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(themeContext, MaterialPageRoute(builder: (_) => CartScreen()));
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Theme.of(themeContext).primaryColor, borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.add, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Text('${product.discountPercent}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
