import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/screens/product_detail_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/shop_screen.dart';

class SeedsScreen extends StatefulWidget {
  const SeedsScreen({super.key});

  @override
  State<SeedsScreen> createState() => _SeedsScreenState();
}

class _SeedsScreenState extends State<SeedsScreen> {
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
      final snapshot = await _firestore.collection('seeds').get();
      if (snapshot.docs.isEmpty) {
        await _seedDatabase();
        final newSnapshot = await _firestore.collection('seeds').get();
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
      debugPrint("Error fetching seeds from Firebase: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _seedDatabase() async {
    List<Product> initialProducts = [
      Product(
        name: 'Arka Rakshak Tomato F1',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 85.0,
        originalPrice: 120.0,
        discountPercent: 29,
        likes: 450,
        quantity: '10 g',
        brand: 'IIHR-Bengaulru',
        description: 'High yielding hybrid tomato seeds, resistant to ToLCV, BW, and EBL. Fruits are firm with good shelf life.',
        suitableCrops: 'Tomato',
      ),
      Product(
        name: 'Tejaswini Chilli Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 95.0,
        originalPrice: 150.0,
        discountPercent: 36,
        likes: 320,
        quantity: '10 g',
        brand: 'Seminis',
        description: 'Early maturing, high heat chilli hybrid, suitable for fresh and dry markets.',
        suitableCrops: 'Chilli',
      ),
      Product(
        name: 'BPT 5204 Paddy Seeds',
        category: 'Cereal',
        image: 'assets/images/logo_round.png',
        currentPrice: 1250.0,
        originalPrice: 1400.0,
        discountPercent: 10,
        likes: 890,
        quantity: '25 kg',
        brand: 'National Seeds',
        description: 'Popular fine grain variety, also known as Samba Mahsuri.',
        suitableCrops: 'Paddy',
      ),
      Product(
        name: 'HD 2967 Wheat Seeds',
        category: 'Cereal',
        image: 'assets/images/logo_round.png',
        currentPrice: 1100.0,
        originalPrice: 1300.0,
        discountPercent: 15,
        likes: 750,
        quantity: '40 kg',
        brand: 'IARI',
        description: 'High yielding, rust resistant variety for timely sown conditions.',
        suitableCrops: 'Wheat',
      ),
      Product(
        name: 'Dekalb 9108 Maize Seeds',
        category: 'Cereal',
        image: 'assets/images/logo_round.png',
        currentPrice: 650.0,
        originalPrice: 750.0,
        discountPercent: 13,
        likes: 410,
        quantity: '4 kg',
        brand: 'Bayer',
        description: 'Elite maize hybrid with bold grains and high yield potential.',
        suitableCrops: 'Maize',
      ),
      Product(
        name: 'Arka Neelkanth Brinjal Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 45.0,
        originalPrice: 60.0,
        discountPercent: 25,
        likes: 180,
        quantity: '5 g',
        brand: 'IIHR',
        description: 'Bacterial wilt resistant variety with purple, oblong fruits.',
        suitableCrops: 'Brinjal',
      ),
      Product(
        name: 'Arka Anamika Okra Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 55.0,
        originalPrice: 80.0,
        discountPercent: 31,
        likes: 240,
        quantity: '50 g',
        brand: 'IIHR',
        description: 'Yellow Vein Mosaic Virus (YVMV) resistant okra variety.',
        suitableCrops: 'Okra',
      ),
      Product(
        name: 'Bhima Super Onion Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 450.0,
        originalPrice: 600.0,
        discountPercent: 25,
        likes: 310,
        quantity: '500 g',
        brand: 'DOGR',
        description: 'High yielding red onion variety suitable for Kharif and late Kharif.',
        suitableCrops: 'Onion',
      ),
      Product(
        name: 'Nantes Carrot Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 75.0,
        originalPrice: 100.0,
        discountPercent: 25,
        likes: 150,
        quantity: '100 g',
        brand: 'Sakata',
        description: 'Coreless, cylindrical carrot variety with sweet taste.',
        suitableCrops: 'Carrot',
      ),
      Product(
        name: 'Pusa Chetki Radish Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 40.0,
        originalPrice: 55.0,
        discountPercent: 27,
        likes: 120,
        quantity: '50 g',
        brand: 'IARI',
        description: 'Summer radish variety, white and mildly pungent.',
        suitableCrops: 'Radish',
      ),
      Product(
        name: 'Pusa Katki Cauliflower Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 120.0,
        originalPrice: 180.0,
        discountPercent: 33,
        likes: 210,
        quantity: '10 g',
        brand: 'IARI',
        description: 'Early maturing cauliflower variety suitable for September harvesting.',
        suitableCrops: 'Cauliflower',
      ),
      Product(
        name: 'Golden Acre Cabbage Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 90.0,
        originalPrice: 130.0,
        discountPercent: 30,
        likes: 190,
        quantity: '10 g',
        brand: 'Namdhari',
        description: 'Early maturing, round-headed cabbage variety.',
        suitableCrops: 'Cabbage',
      ),
      Product(
        name: 'Poinsette Cucumber Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 60.0,
        originalPrice: 85.0,
        discountPercent: 29,
        likes: 270,
        quantity: '50 g',
        brand: 'East-West',
        description: 'Multivirus resistant cucumber variety with dark green fruits.',
        suitableCrops: 'Cucumber',
      ),
      Product(
        name: 'Pusa Do Mausami Bitter Gourd',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 50.0,
        originalPrice: 70.0,
        discountPercent: 28,
        likes: 140,
        quantity: '20 g',
        brand: 'IARI',
        description: 'Popular variety suitable for both spring-summer and rainy seasons.',
        suitableCrops: 'Bitter Gourd',
      ),
      Product(
        name: 'Pusa Naveen Bottle Gourd',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 40.0,
        originalPrice: 60.0,
        discountPercent: 33,
        likes: 160,
        quantity: '20 g',
        brand: 'IARI',
        description: 'Prolific bearer with long, cylindrical, uniform fruits.',
        suitableCrops: 'Bottle Gourd',
      ),
      Product(
        name: 'Arka Suryamukhi Pumpkin Seeds',
        category: 'Vegetable',
        image: 'assets/images/logo_round.png',
        currentPrice: 65.0,
        originalPrice: 90.0,
        discountPercent: 27,
        likes: 110,
        quantity: '50 g',
        brand: 'IIHR',
        description: 'Small, round, orange-fleshed pumpkin variety.',
        suitableCrops: 'Pumpkin',
      ),
      Product(
        name: 'Arka Manik Watermelon Seeds',
        category: 'Fruit',
        image: 'assets/images/logo_round.png',
        currentPrice: 110.0,
        originalPrice: 160.0,
        discountPercent: 31,
        likes: 380,
        quantity: '50 g',
        brand: 'IIHR',
        description: 'Triple resistant variety (Anthracnose, Powdery Mildew, Downy Mildew).',
        suitableCrops: 'Watermelon',
      ),
      Product(
        name: 'Arka Jeet Muskmelon Seeds',
        category: 'Fruit',
        image: 'assets/images/logo_round.png',
        currentPrice: 95.0,
        originalPrice: 140.0,
        discountPercent: 32,
        likes: 220,
        quantity: '50 g',
        brand: 'IIHR',
        description: 'Early maturing, high sugar content muskmelon variety.',
        suitableCrops: 'Muskmelon',
      ),
      Product(
        name: 'All Green Spinach Seeds',
        category: 'Leafy',
        image: 'assets/images/logo_round.png',
        currentPrice: 35.0,
        originalPrice: 50.0,
        discountPercent: 30,
        likes: 290,
        quantity: '100 g',
        brand: 'IARI',
        description: 'High yielding variety with tender, green leaves.',
        suitableCrops: 'Spinach',
      ),
      Product(
        name: 'Pant Haritma Coriander',
        category: 'Spices',
        image: 'assets/images/logo_round.png',
        currentPrice: 45.0,
        originalPrice: 65.0,
        discountPercent: 30,
        likes: 340,
        quantity: '100 g',
        brand: 'GBPUAT-Pantnagar',
        description: 'Late bolting variety with high essential oil content and broad, dark green leaves.',
        suitableCrops: 'Coriander',
      ),
    ];

    WriteBatch batch = _firestore.batch();
    for (var prod in initialProducts) {
      DocumentReference docRef = _firestore.collection('seeds').doc();
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
      title: Text(TranslationService.translate('seeds'), style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
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
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.grass, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                            )
                          : product.image.startsWith('base64:')
                              ? Image.memory(
                                  base64Decode(product.image.substring(7)),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.grass, size: 50, color: isDark ? Colors.white12 : Colors.black12),
                                )
                              : Image.asset(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.grass, size: 50, color: isDark ? Colors.white12 : Colors.black12),
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
                      Text('₹${product.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(themeContext).textTheme.bodyLarge?.color)),
                      const SizedBox(width: 4),
                      Text('₹${product.originalPrice.toInt()}', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey, fontSize: 9, decoration: TextDecoration.lineThrough)),
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
                                  Navigator.push(themeContext, MaterialPageRoute(builder: (_) => const CartScreen()));
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
