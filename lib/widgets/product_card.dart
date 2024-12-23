import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: CachedNetworkImage(
                    imageUrl: product.images.isNotEmpty ? product.images.first.src.replaceAll(r'\\', '/') : '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, _) {
                      final isInWishlist = wishlistProvider.isInWishlist(product.id);
                      return CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        child: IconButton(
                          icon: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            if (isInWishlist) {
                              wishlistProvider.removeFromWishlist(product.id);
                            } else {
                              wishlistProvider.addToWishlist(product);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'خصم ${_calculateDiscount()}%',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.averageRating} (${product.ratingCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.onSale) ...[
                    Row(
                      children: [
                        Text(
                          'AED ${product.salePrice}',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AED ${product.regularPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      'AED ${product.regularPrice}',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, _) {
                        final isInCart = cartProvider.isInCart(product.id);
                        return ElevatedButton.icon(
                          onPressed: isInCart
                              ? null
                              : () => cartProvider.addToCart(product),
                          icon: Icon(
                            isInCart ? Icons.check : Icons.shopping_cart,
                            size: 18,
                          ),
                          label: Text(
                            isInCart ? 'تم الإضافة' : 'أضف للسلة',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        );
                      },
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

  int _calculateDiscount() {
    if (!product.onSale) return 0;
    final regular = double.tryParse(product.regularPrice) ?? 0;
    final sale = double.tryParse(product.salePrice) ?? 0;
    if (regular == 0) return 0;
    return ((regular - sale) / regular * 100).round();
  }
}
