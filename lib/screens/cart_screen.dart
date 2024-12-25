import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart' as models;
import '../services/cart_service.dart';
import '../utils/currency_formatter.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  final CartService _cartService;

  const CartScreen({Key? key, required CartService cartService})
      : _cartService = cartService,
        super(key: key);

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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.product.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
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
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              // صورة المنتج
                              if (item.product.images.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.images.first.src,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                    Text(
                                      CurrencyFormatter.format(
                                        _getPrice(item),
                                      ),
                                      style: GoogleFonts.cairo(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        _cartService.updateQuantity(
                                          item.product.id.toString(),
                                          item.quantity - 1,
                                        );
                                      } else {
                                        _cartService.removeItem(
                                          item.product.id.toString(),
                                        );
                                      }
                                    },
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      _cartService.updateQuantity(
                                        item.product.id.toString(),
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المجموع',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              _calculateTotal(items),
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
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
                                            builder: (context) =>
                                                const LoginScreen(),
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

                            final cartItems = items.map((item) => {
                              'id': item.product.id,
                              'quantity': item.quantity,
                              'name': item.product.name,
                              'price': _getPrice(item),
                            }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                  total: _calculateTotal(items),
                                  cartItems: cartItems,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Text(
                            'متابعة الشراء',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
}
