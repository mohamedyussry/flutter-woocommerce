import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../widgets/add_to_cart_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';

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
  final Map<String, String> _selectedAttributes = {};
  ProductVariation? _selectedVariation;

  @override
  void initState() {
    super.initState();
    _initializeAttributes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeAttributes() {
    if (widget.product.attributes.isEmpty) return;
    
    for (var attribute in widget.product.attributes) {
      if (attribute.options.isNotEmpty) {
        _selectedAttributes[attribute.name] = attribute.options.first;
      }
    }
    _updateSelectedVariation();
  }

  void _updateSelectedVariation() {
    if (widget.product.variations.isEmpty) return;

    _selectedVariation = widget.product.variations.firstWhere(
      (variation) {
        return variation.attributes.entries.every((entry) {
          return _selectedAttributes[entry.key] == entry.value;
        });
      },
      orElse: () => widget.product.variations.first,
    );
    setState(() {});
  }

  Future<void> _shareProduct() async {
    final url = 'https://naturerepublic.ae/product/${widget.product.slug}';
    try {
      await Share.share(
        '${widget.product.name}\n\n'
        'تسوق الآن من متجر نيتشر ريببلك:\n'
        '$url',
        subject: widget.product.name,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، حدث خطأ أثناء المشاركة',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
  }

  Widget _buildAttributeSelector() {
    if (widget.product.attributes.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.product.attributes.map((attribute) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attribute.name,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: attribute.options.map((option) {
                    final isSelected = _selectedAttributes[attribute.name] == option;
                    return ChoiceChip(
                      label: Text(
                        option,
                        style: GoogleFonts.cairo(),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedAttributes[attribute.name] = option;
                            _updateSelectedVariation();
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final variation = _selectedVariation;
    final hasVariations = widget.product.variations.isNotEmpty;
    
    String price = hasVariations && variation != null 
        ? variation.price 
        : widget.product.price;
    
    String? regularPrice = hasVariations && variation != null 
        ? variation.regularPrice 
        : widget.product.regularPrice;
    
    bool isOnSale = hasVariations && variation != null 
        ? variation.onSale 
        : widget.product.onSale;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (isOnSale && regularPrice != null && regularPrice.isNotEmpty) ...[
            Text(
              '$regularPrice درهم',
              style: GoogleFonts.cairo(
                fontSize: 16,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '$price درهم',
            style: GoogleFonts.cairo(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
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
                          dotColor: Theme.of(context).colorScheme.primary.withAlpha(102),
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
            _buildPriceSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.name,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.product.shortDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Html(
                  data: widget.product.shortDescription,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                    ),
                  },
                ),
              ),
            _buildAttributeSelector(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AddToCartButton(
                product: widget.product,
                variation: _selectedVariation,
                enabled: widget.product.variations.isEmpty || _selectedVariation != null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
