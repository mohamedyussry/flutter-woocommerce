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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts();
      context.read<CategoriesProvider>().fetchCategories();
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement search
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // TODO: Navigate to cart
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CategorySlider(),
                  const SizedBox(height: 16),
                  const CategoryList(),
                  const SizedBox(height: 16),
                  const FeaturedProducts(),
                  const SizedBox(height: 16),
                  const NewProducts(),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: Consumer<ProductsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (provider.error != null && provider.products.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                provider.refreshProducts();
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.products.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final product = provider.products[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  product: product,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (product.images.isNotEmpty)
                                        Hero(
                                          tag: 'product_${product.id}_all',
                                          child: Image.network(
                                            product.images.first.src,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      if (product.onSale)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'خصم ${_calculateDiscount(product)}%',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError,
                                                fontSize: 12,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (product.onSale) ...[
                                          Text(
                                            'AED ${product.salePrice}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'AED ${product.regularPrice}',
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ] else
                                          Text(
                                            'AED ${product.regularPrice}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount:
                          provider.products.length + (provider.isLoading ? 1 : 0),
                    ),
                  );
                },
              ),
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
