import 'package:flutter/material.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/services/cart_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // for Product model
import 'package:smart_farm/screens/product_detail_screen.dart';

class PesticidesScreen extends StatefulWidget {
  const PesticidesScreen({super.key});

  @override
  State<PesticidesScreen> createState() => _PesticidesScreenState();
}

class _PesticidesScreenState extends State<PesticidesScreen> {
  static final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Azospirillum Bio-Fertilizer',
      image: 'assets/images/azospirillum_bio_bottle.png',
      currentPrice: 250.0,
      originalPrice: 300.0,
      discountPercent: 16,
      likes: 120,
      brand: 'AgriLife',
      quantity: '500 ml',
      description: 'Natural nitrogen-fixing bio-fertilizer for all crops.',
      suitableCrops: 'All crops',
    ),
    Product(
      id: 'p2',
      name: 'Zevictra TC Insecticide',
      image: 'assets/images/zevictra_tc.png',
      currentPrice: 850.0,
      originalPrice: 1000.0,
      discountPercent: 15,
      likes: 85,
      brand: 'UPL',
      quantity: '1 L',
      description: 'Effective termite and pest control for soil applications.',
      suitableCrops: 'Sugarcane, Wheat, Ornamentals',
    ),
    Product(
      id: 'p3',
      name: 'Trichoderma Agrilife',
      image: 'assets/images/trichoderma_agrilife_box.png',
      currentPrice: 450.0,
      originalPrice: 550.0,
      discountPercent: 18,
      likes: 210,
      brand: 'AgriLife',
      quantity: '1 kg',
      description: 'Bio-fungicide for controlling soil-borne diseases.',
      suitableCrops: 'Vegetables, Pulses, Cereals',
    ),
    Product(
      id: 'p4',
      name: 'Bio Compost SKV',
      image: 'assets/images/bio_compost_skv.png',
      currentPrice: 120.0,
      originalPrice: 150.0,
      discountPercent: 20,
      likes: 340,
      brand: 'SKV Foods',
      quantity: '2 kg',
      description: 'Organic enriched compost for soil health and fertility.',
      suitableCrops: 'Kitchen Garden, Field Crops',
    ),
    Product(
      id: 'p5',
      name: 'Azospirillum Natural Fertilizer',
      image: 'assets/images/azospirillum_fertilizer.png',
      currentPrice: 320.0,
      originalPrice: 400.0,
      discountPercent: 20,
      likes: 150,
      brand: 'AgriLife',
      quantity: '500 g',
      description: 'Powdered bio-fertilizer for enhanced plant growth.',
      suitableCrops: 'Rice, Maize, Wheat',
    ),
    Product(
      id: 'p6',
      name: 'Kribhco Zinc Sulphate',
      image: 'assets/images/kribhco_zinc_sulphate.png',
      currentPrice: 410.0,
      originalPrice: 500.0,
      discountPercent: 18,
      likes: 230,
      brand: 'Kribhco',
      quantity: '1 kg',
      description: 'High-quality zinc supplement for soil health.',
      suitableCrops: 'Cash crops, Fruit trees',
    ),
    Product(
      id: 'p7',
      name: 'Organic Growth Promoter',
      image: 'assets/images/logo_round.png',
      currentPrice: 180.0,
      originalPrice: 240.0,
      discountPercent: 25,
      likes: 95,
      brand: 'Smart Farm',
      quantity: '250 ml',
      description: 'General purpose growth promoter for all plants.',
      suitableCrops: 'Flowers, Vegetables',
    ),
    Product(
      id: 'p8',
      name: 'Bio-Nutrient Supplement',
      image: 'assets/images/logo.png',
      currentPrice: 220.0,
      originalPrice: 280.0,
      discountPercent: 21,
      likes: 112,
      brand: 'AgriCare',
      quantity: '500 g',
      description: 'Essential micro-nutrients for better flowering.',
      suitableCrops: 'Fruit crops',
    ),
    Product(
      id: 'p9',
      name: 'Soil Health Conditioner',
      image: 'assets/images/farm_bg.jpg',
      currentPrice: 550.0,
      originalPrice: 700.0,
      discountPercent: 21,
      likes: 260,
      brand: 'FieldMaster',
      quantity: '5 kg',
      description: 'Restores soil structure and helps in water retention.',
      suitableCrops: 'Heavy clay soils',
    ),
    Product(
      id: 'p10',
      name: 'Raitha Bandhu Special Tonic',
      image: 'assets/images/raitha_bandhu_icon.png',
      currentPrice: 380.0,
      originalPrice: 450.0,
      discountPercent: 15,
      likes: 89,
      brand: 'Govt. Approved',
      quantity: '1 L',
      description: 'Special formulation for better crop yield in dry lands.',
      suitableCrops: 'Dry land agriculture',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, 
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, _products[index]);
            },
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text('Pesticides', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: isDark ? Colors.white70 : Colors.black54),
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

  Widget _buildProductCard(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2)),
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
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50, color: isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.brand} • ${product.quantity}',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₹${product.currentPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(width: 8),
                      Text('₹${product.originalPrice.toInt()}', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(border: Border.all(color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                        child: Icon(Icons.bookmark_border, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      InkWell(
                        onTap: () {
                          CartService.instance.addToCart(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ${TranslationService.translate('added_to_cart')}'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'VIEW',
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFF1B4332), borderRadius: BorderRadius.circular(4)), 
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
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                   Icon(Icons.favorite, color: isDark ? Colors.white38 : Colors.grey, size: 16),
                  const SizedBox(height: 2),
                  Text('${product.likes} Likes', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 8)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
