import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'orders_screen.dart';
import '../screens/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();

  @override
  void initState() {
    super.initState();
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
      body: ValueListenableBuilder<List<CartItem>>(
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.product.id),
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
                onDismissed: (direction) {
                  _cartService.removeItem(item.product.id);
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrl,
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
                            '${item.product.price} درهم',
                            style: GoogleFonts.cairo(
                              color: Colors.green,
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
                            _cartService.updateQuantity(
                              item.product.id,
                              item.quantity - 1,
                            );
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
                              item.product.id,
                              item.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<double>(
        valueListenable: _cartService.total,
        builder: (context, total, child) {
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
                ElevatedButton(
                  onPressed: total > 0
                      ? () async {
                          final authService = AuthService();
                          if (!authService.isLoggedIn) {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.account_circle_outlined,
                                        size: 64,
                                        color: Colors.green.shade200,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'تسجيل الدخول مطلوب',
                                        style: GoogleFonts.cairo(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'يجب تسجيل الدخول أولاً لإتمام عملية الشراء',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Close dialog
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginScreen(),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'تسجيل الدخول',
                                              style: GoogleFonts.cairo(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'إلغاء',
                                              style: GoogleFonts.cairo(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            return;
                          }

                          // Navigate to checkout screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(total: total),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'إتمام الشراء',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
