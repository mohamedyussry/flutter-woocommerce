import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final CartService _cartService = CartService();
  bool _isAddingToCart = false;

  double _calculateDiscount() {
    if (widget.product.regularPrice.isEmpty || widget.product.salePrice.isEmpty) return 0;
    final regularPrice = double.tryParse(widget.product.regularPrice) ?? 0;
    final salePrice = double.tryParse(widget.product.salePrice) ?? 0;
    if (regularPrice == 0) return 0;
    return ((regularPrice - salePrice) / regularPrice) * 100;
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      _cartService.addItem(widget.product, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة ${widget.product.name} إلى السلة'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'عرض السلة',
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _buildProductImage() {
    if (widget.product.images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }

    String imageUrl = widget.product.images.first.src.replaceAll(r'\\', '/');
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 50),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discount = _calculateDiscount();
    final hasDiscount = widget.product.salePrice.isNotEmpty && discount > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: _buildProductImage(),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${discount.toStringAsFixed(0)}% خصم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${hasDiscount ? widget.product.salePrice : widget.product.regularPrice} درهم',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product.regularPrice} درهم',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<CartItem>>(
                    valueListenable: _cartService.items,
                    builder: (context, items, child) {
                      final isInCart = items.any((item) => 
                        item.product.id.toString() == widget.product.id.toString()
                      );
                      return SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: isInCart || _isAddingToCart ? null : _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            padding: EdgeInsets.zero,
                          ),
                          child: _isAddingToCart
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isInCart ? 'في السلة' : 'إضافة للسلة',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
