import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_farm/screens/cart_screen.dart';
import 'package:smart_farm/screens/shop_screen.dart'; // for Product
import 'package:smart_farm/services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF4C53A5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF0F0F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Product', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              widget.product.isLiked ? Icons.favorite : Icons.favorite,
              color: widget.product.isLiked ? Colors.red : (isDark ? Colors.white24 : const Color(0xFFF44336)),
            ),
            onPressed: () {
              setState(() {
                widget.product.isLiked = !widget.product.isLiked;
              });
            },
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${(widget.product.currentPrice * quantity).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  CartService.instance.addMultipleToCart(widget.product, quantity);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $quantity x ${widget.product.name} to cart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'VIEW',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                label: const Text('Add To Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF0F0F5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            child: Center(
                child: widget.product.image.startsWith('http')
                    ? Image.network(
                        widget.product.image,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100, color: isDark ? Colors.white12 : Colors.black12),
                      )
                    : widget.product.image.startsWith('base64:')
                        ? Image.memory(
                            widget.product.decodedImage ?? (() {
                              final bytes = base64Decode(widget.product.image.substring(7));
                              widget.product.setDecodedImage(bytes);
                              return bytes;
                            })(),
                            height: 250,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100, color: isDark ? Colors.white12 : Colors.black12),
                          )
                        : Image.asset(
                            widget.product.image,
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100, color: isDark ? Colors.white12 : Colors.black12),
                          ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index <= 3 ? Icons.star : Icons.star,
                            color: index <= 3 ? primaryColor : (isDark ? Colors.white12 : Colors.grey.shade400),
                            size: 18,
                          );
                        }),
                      ),
                      Row(
                        children: [
                          _buildQtyBtn(context, Icons.remove, () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          }),
                          const SizedBox(width: 12),
                          Text(quantity.toString().padLeft(2, '0'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                          const SizedBox(width: 12),
                          _buildQtyBtn(context, Icons.add, () {
                            setState(() => quantity++);
                          }),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.product.description.isEmpty ? 'This is a more detailed description of the product. you can write here more about the product. this is lengthy description.' : widget.product.description,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sizes / Attributes
                  Row(
                    children: [
                      Text('Brand: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(width: 12),
                      _buildChip(context, widget.product.brand),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Crops: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(width: 12),
                      _buildChip(context, widget.product.suitableCrops),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Size: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(width: 22),
                      _buildChip(context, widget.product.quantity),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Theme.of(context).primaryColor : const Color(0xFF4C53A5);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ]
        ),
        child: Icon(icon, size: 20, color: primaryColor),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    if (label.isEmpty) label = 'N/A';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}
