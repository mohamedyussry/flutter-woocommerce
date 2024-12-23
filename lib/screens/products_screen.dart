import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final productsProvider = context.read<ProductsProvider>();
    await productsProvider.fetchProducts(refresh: true);
    await productsProvider.fetchCategories();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      await context.read<ProductsProvider>().fetchProducts();
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        centerTitle: true,
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading && productsProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productsProvider.error.isNotEmpty && productsProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productsProvider.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadInitialData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final products = productsProvider.products;
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منتجات متاحة حالياً',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productsProvider.refreshProducts(),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length + (productsProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == products.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final product = products[index];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = product.on_sale && product.sale_price != product.regular_price;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (product.mainImage.isNotEmpty)
                  Image.network(
                    product.mainImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error));
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                else
                  const Center(child: Icon(Icons.image_not_supported)),
                if (!product.isInStock)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: const Text(
                      'نفذت الكمية',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'خصم',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (hasDiscount) ...[
                    Text(
                      'AED ${product.sale_price}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AED ${product.regular_price}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ] else
                    Text(
                      'AED ${product.price}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
