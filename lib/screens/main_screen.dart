import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final String _whatsappNumber = '+971585002007'; // رقم الواتس اب
  final CartService _cartService = CartService();

  void _launchWhatsApp() async {
    final url = 'https://wa.me/$_whatsappNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح WhatsApp'),
          ),
        );
      }
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const Center(child: Text('البحث')),
    const Center(child: Text('المفضلة')),
    const CartScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366), // لون واتساب
        child: const FaIcon(FontAwesomeIcons.whatsapp, size: 28),
      ),
      bottomNavigationBar: ValueListenableBuilder<List<CartItem>>(
        valueListenable: _cartService.items,
        builder: (context, items, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  activeIcon: Icon(Icons.category),
                  label: 'الفئات',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  activeIcon: Icon(Icons.search),
                  label: 'البحث',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'المفضلة',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      if (items.isNotEmpty)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${items.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (items.isNotEmpty)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${items.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'السلة',
                ),
              ],
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
            ),
          );
        },
      ),
    );
  }
}
