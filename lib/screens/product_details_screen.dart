import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/add_to_cart_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.images.isNotEmpty) ...[
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.images[index].src,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
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
                        );
                      },
                    ),
                  ),
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 8,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: widget.product.images.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ] else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.product.onSale) ...[
                    Row(
                      children: [
                        Text(
                          '${widget.product.salePrice} درهم',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.product.regularPrice} درهم',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      '${widget.product.regularPrice} درهم',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(height: 16),
                  if (widget.product.shortDescription.isNotEmpty) ...[
                    Text(
                      'الوصف',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.shortDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Product Attributes
                  if (widget.product.attributes.isNotEmpty) ...[
                    Text(
                      'المواصفات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.attributes.map((attribute) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${attribute.name}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(attribute.options.join(', ')),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AddToCartButton(product: widget.product),
        ),
      ),
    );
  }
}
