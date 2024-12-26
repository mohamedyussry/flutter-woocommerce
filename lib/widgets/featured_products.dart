import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';
import 'product_card.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({super.key});

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
                'منتجات مميزة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to featured products screen
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null && provider.products.isEmpty) {
                return Center(
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              final featuredProducts = provider.products
                  .where((product) => product.featured)
                  .toList();

              if (featuredProducts.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد منتجات مميزة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
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
