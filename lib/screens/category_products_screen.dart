import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import 'product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'newest';
  bool _isFilterVisible = false;
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  void _loadProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().fetchProducts(
        refresh: true,
        categoryId: widget.categoryId,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ProductsProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ترتيب حسب:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('الأحدث'),
                        selected: _sortBy == 'newest',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _sortBy = 'newest');
                            _loadProducts();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('السعر: من الأقل للأعلى'),
                        selected: _sortBy == 'price_asc',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _sortBy = 'price_asc');
                            _loadProducts();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('السعر: من الأعلى للأقل'),
                        selected: _sortBy == 'price_desc',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _sortBy = 'price_desc');
                            _loadProducts();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'نطاق السعر:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_priceRange.start.round()} درهم',
                      '${_priceRange.end.round()} درهم',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    onChangeEnd: (RangeValues values) {
                      _loadProducts();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, productsProvider, child) {
                if (productsProvider.isLoading && productsProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productsProvider.error != null && productsProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(productsProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final products = productsProvider.products;

                if (products.isEmpty) {
                  return const Center(
                    child: Text('لا توجد منتجات في هذه الفئة'),
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
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: products.length + (productsProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final product = products[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first.src,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.onSale)
                    Row(
                      children: [
                        Text(
                          '${product.salePrice} درهم',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.regularPrice} درهم',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '${product.regularPrice} درهم',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
