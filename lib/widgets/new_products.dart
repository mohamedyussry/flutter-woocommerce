import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';
import 'product_card.dart';

class NewProducts extends StatelessWidget {
  const NewProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'وصل حديثاً',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to new products screen
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: Consumer<ProductsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null && provider.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.error!),
                      ElevatedButton(
                        onPressed: () => provider.fetchProducts(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              final newProducts = provider.products
                  .toList()
                  ..sort((a, b) {
                    final aDate = DateTime.tryParse(a.dateCreated) ?? DateTime(1970);
                    final bDate = DateTime.tryParse(b.dateCreated) ?? DateTime(1970);
                    return bDate.compareTo(aDate);
                  });
              final displayProducts = newProducts.take(10).toList();

              if (displayProducts.isEmpty) {
                return const Center(
                  child: Text('لا توجد منتجات جديدة'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  return SizedBox(
                    width: 200,
                    child: ProductCard(
                      product: product,
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
