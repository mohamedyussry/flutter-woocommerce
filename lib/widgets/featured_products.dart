import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/product_details_screen.dart';
import '../services/woocommerce_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeaturedProducts extends StatefulWidget {
  const FeaturedProducts({Key? key}) : super(key: key);

  @override
  State<FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
  late Future<List<dynamic>> _featuredProductsFuture;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  void _loadFeaturedProducts() {
    final woocommerce = WooCommerceService();
    _featuredProductsFuture = woocommerce.getFeaturedProducts();
  }

  void _navigateToFeaturedProducts() {
    // سيتم تنفيذ التنقل إلى صفحة المنتجات المميزة لاحقاً
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'منتجات مميزة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _navigateToFeaturedProducts,
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: FutureBuilder<List<dynamic>>(
            future: _featuredProductsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: GoogleFonts.cairo(),
                  ),
                );
              }

              final products = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product['id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product['images'] != null &&
                                (product['images'] as List).isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: product['images'][0]['src'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product['price']} درهم',
                                    style: GoogleFonts.cairo(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
