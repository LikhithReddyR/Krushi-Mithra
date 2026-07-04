import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/seeds_screen.dart';
import 'package:smart_farm/screens/pesticides_screen.dart';
import 'package:smart_farm/screens/machinery_screen.dart';
import 'package:smart_farm/screens/fertilizers_screen.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCategoryCard(
                      TranslationService.translate('seeds'),
                      Icons.grass,
                      const Color(0xFF1E3A2B),
                      () {
                        Navigator.push(context, FastPageRoute(page: const SeedsScreen()));
                      },
                      context,
                    ),
                    _buildCategoryCard(
                      TranslationService.translate('pesticides_booking'),
                      Icons.science,
                      const Color(0xFF1E3A2B),
                      () {
                        Navigator.push(context, FastPageRoute(page: const PesticidesScreen()));
                      },
                      context,
                    ),
                    _buildCategoryCard(
                      'Machinery Rental',
                      Icons.construction,
                      const Color(0xFF1B5E20),
                      () {
                        Navigator.push(context, FastPageRoute(page: const MachineryScreen()));
                      },
                      context,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor.withOpacity(0.15) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColor : color),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: Text('Krushi Angadi', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: Icon(Icons.search, color: iconColor), onPressed: () {}),
        IconButton(icon: Icon(Icons.notifications_none, color: iconColor), onPressed: () {
          Navigator.push(context, FastPageRoute(page: const NotificationsScreen()));
        }),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: iconColor),
              onPressed: () {
                Navigator.push(context, FastPageRoute(page: const CartScreen()));
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
                    decoration: const BoxDecoration(color: Color(0xFF1976D2), shape: BoxShape.circle),
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
}

class Product {
  final String id;
  final String name;
  final String image;
  final double currentPrice;
  final double originalPrice;
  final int discountPercent;
  final int likes;
  bool isLiked;
  final String category;
  final String quantity;
  final String brand;
  final String description;
  final String suitableCrops;
  Uint8List? _decodedImage;

  Uint8List? get decodedImage => _decodedImage;
  void setDecodedImage(Uint8List bytes) => _decodedImage = bytes;

  Product({
    this.id = '',
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.originalPrice,
    required this.discountPercent,
    required this.likes,
    this.isLiked = false,
    this.category = '',
    this.quantity = '',
    this.brand = '',
    this.description = '',
    this.suitableCrops = '',
  });

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      originalPrice: map['originalPrice']?.toDouble() ?? 0.0,
      discountPercent: map['discountPercent']?.toInt() ?? 0,
      likes: map['likes']?.toInt() ?? 0,
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      suitableCrops: map['suitableCrops'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'currentPrice': currentPrice,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'likes': likes,
      'category': category,
      'quantity': quantity,
      'brand': brand,
      'description': description,
      'suitableCrops': suitableCrops,
    };
  }
}
