import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart' as models;
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartService _cartService;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _cartService.loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سلة المشتريات',
          style: GoogleFonts.cairo(),
        ),
      ),
      body: ValueListenableBuilder<List<models.CartItem>>(
        valueListenable: _cartService.items,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartList(items);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<List<models.CartItem>>(
        valueListenable: _cartService.items,
        builder: (context, items, child) {
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildBottomBar(items);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<models.CartItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key(item.product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) => _handleDismiss(context, item),
          child: _buildCartItem(item),
        );
      },
    );
  }

  Widget _buildCartItem(models.CartItem item) {
    return Row(
      children: [
        _buildProductImage(item),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildPriceRow(item),
            ],
          ),
        ),
        _buildQuantityControls(item),
      ],
    );
  }

  Widget _buildProductImage(models.CartItem item) {
    if (item.product.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.product.images.first.src,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildPriceRow(models.CartItem item) {
    return Row(
      children: [
        Text(
          _getPrice(item),
          style: GoogleFonts.cairo(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' × ${item.quantity}',
          style: GoogleFonts.cairo(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'درهم',
          style: GoogleFonts.cairo(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(models.CartItem item) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => _updateQuantity(item, item.quantity - 1),
        ),
        Text(
          item.quantity.toString(),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _updateQuantity(item, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildBottomBar(List<models.CartItem> items) {
    final total = _calculateTotal(items);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع:',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$total درهم',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _handleCheckout(context, total),
              child: Text(
                'متابعة الشراء',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDismiss(BuildContext context, models.CartItem item) {
    _cartService.removeItem(item.product.id.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حذف ${item.product.name} من السلة',
          style: GoogleFonts.cairo(),
        ),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            _cartService.addItem(item.product);
          },
        ),
      ),
    );
  }

  void _updateQuantity(models.CartItem item, int newQuantity) {
    if (newQuantity < 1) {
      _cartService.removeItem(item.product.id.toString());
    } else {
      _cartService.updateQuantity(item.product.id.toString(), newQuantity);
    }
  }

  String _getPrice(models.CartItem item) {
    try {
      if (item.product.onSale && item.product.salePrice.isNotEmpty) {
        return item.product.salePrice;
      }
      return item.product.regularPrice;
    } catch (e) {
      print('Error getting price: $e');
      return '0';
    }
  }

  double _calculateTotal(List<models.CartItem> items) {
    return items.fold<double>(
      0,
      (sum, item) {
        try {
          String priceStr = _getPrice(item);
          priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.parse(priceStr);
          return sum + (price * item.quantity);
        } catch (e) {
          print('Error calculating total: $e');
          return sum;
        }
      },
    );
  }

  void _handleCheckout(BuildContext context, double total) {
    if (!_authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'تسجيل الدخول مطلوب',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'يجب تسجيل الدخول أولاً لإتمام عملية الشراء',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: Text(
                'تسجيل الدخول',
                style: GoogleFonts.cairo(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(total: total),
      ),
    );
  }
}
