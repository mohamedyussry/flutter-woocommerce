import 'package:flutter/material.dart';
import '../models/product.dart';

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
    // TODO: Implement add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة المنتج إلى السلة'),
        duration: Duration(seconds: 2),
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
            Text(
              'المجموع: ${(double.parse(widget.product.regularPrice) * _quantity).toStringAsFixed(2)} درهم',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
