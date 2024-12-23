import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class AddToCartButton extends StatefulWidget {
  final Product product;

  const AddToCartButton({
    super.key,
    required this.product,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  int _quantity = 1;
  final CartService _cartService = CartService();

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    _cartService.addItem(widget.product, _quantity);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _decrementQuantity,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementQuantity,
                ),
              ],
            ),
            ValueListenableBuilder<List<CartItem>>(
              valueListenable: _cartService.items,
              builder: (context, items, child) {
                final isInCart = items.any((item) => item.product.id.toString() == widget.product.id.toString());
                return ElevatedButton(
                  onPressed: isInCart ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    isInCart ? 'في السلة' : 'إضافة للسلة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.product.stockStatus == 'instock'
                ? _addToCart
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.product.stockStatus == 'instock'
                  ? 'إضافة إلى السلة'
                  : 'نفذت الكمية',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
