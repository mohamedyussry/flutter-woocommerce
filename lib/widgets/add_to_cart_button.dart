import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class AddToCartButton extends StatefulWidget {
  final Product product;
  final ProductVariation? variation;
  final bool enabled;

  const AddToCartButton({
    super.key,
    required this.product,
    this.variation,
    this.enabled = true,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  int _quantity = 1;
  final CartService _cartService = CartService();
  bool _isLoading = false;

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

  Future<void> _addToCart() async {
    if (!widget.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار جميع الخيارات المتاحة'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _cartService.addItem(
        widget.product,
        _quantity,
        variation: widget.variation,
      );

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _decrementQuantity,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              _quantity.toString(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: _incrementQuantity,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.enabled && !_isLoading ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'إضافة إلى السلة',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
