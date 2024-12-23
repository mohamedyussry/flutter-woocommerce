import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/categories_provider.dart';
import '../models/product.dart';
import 'product_details_screen.dart';
import '../widgets/category_list.dart';
import '../widgets/featured_products.dart';
import '../widgets/new_products.dart';
import '../widgets/category_slider.dart';
import 'category_products_screen.dart';
import 'cart_screen.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart' as models;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
      context.read<CategoriesProvider>().fetchCategories();
      _cartService.loadCart();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ProductsProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductsProvider>().refreshProducts();
          await context.read<CategoriesProvider>().fetchCategories();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Nature Republic'),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.6,
                        minChildSize: 0.3,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) => CategoryList(
                          scrollController: scrollController,
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement search
                  },
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                    ValueListenableBuilder<List<models.CartItem>>(
                      valueListenable: _cartService.items,
                      builder: (context, items, child) {
                        if (items.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              items.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: CategorySlider(),
            ),
            const SliverToBoxAdapter(
              child: FeaturedProducts(),
            ),
            const SliverToBoxAdapter(
              child: NewProducts(),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDiscount(Product product) {
    if (!product.onSale) return 0;
    final regular = double.tryParse(product.regularPrice) ?? 0;
    final sale = double.tryParse(product.salePrice) ?? 0;
    if (regular == 0) return 0;
    return ((regular - sale) / regular * 100).round();
  }
}
