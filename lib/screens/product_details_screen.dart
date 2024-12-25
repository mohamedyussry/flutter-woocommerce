import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../services/woocommerce_service.dart';
import '../utils/currency_formatter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Map<String, dynamic>> _productFuture;
  late Future<List<dynamic>> _variationsFuture;
  late Future<List<dynamic>> _reviewsFuture;
  late Future<List<dynamic>> _relatedProductsFuture;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  
  ProductVariation? selectedVariation;
  Map<String, String> selectedAttributes = {};
  int quantity = 1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProductData() {
    final woocommerce = WooCommerceService();
    _productFuture = woocommerce.getProductDetails(widget.productId);
    _variationsFuture = woocommerce.getProductVariations(widget.productId);
    _reviewsFuture = woocommerce.getProductReviews(widget.productId);
    _relatedProductsFuture = woocommerce.getRelatedProducts(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: GoogleFonts.cairo(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadProductData();
                      });
                    },
                    child: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                ],
              ),
            );
          }

          final product = Product.fromJson(snapshot.data!);
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageGallery(product.images),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // TODO: إضافة للمفضلة
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تمت الإضافة للمفضلة',
                            style: GoogleFonts.cairo(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: مشاركة المنتج
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'جاري مشاركة المنتج...',
                            style: GoogleFonts.cairo(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // محتوى المنتج
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المنتج
                        Text(
                          product.name,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // السعر
                        _buildPriceSection(product),
                        
                        const SizedBox(height: 16),
                        
                        // الوصف المختصر
                        Text(
                          product.shortDescription,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // خيارات المنتج
              if (product.type == 'variable')
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildVariationOptions(product),
                    ),
                  ),
                ),

              // حالة المخزون والكمية
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStockStatus(product),
                        const SizedBox(height: 16),
                        _buildQuantitySelector(),
                      ],
                    ),
                  ),
                ),
              ),

              // زر إضافة للسلة
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildAddToCartButton(product),
                ),
              ),

              // الوصف الكامل
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ExpansionTile(
                    title: Text(
                      'الوصف',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          product.description,
                          style: GoogleFonts.cairo(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // المراجعات
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ExpansionTile(
                    title: Text(
                      'المراجعات',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildReviews(),
                      ),
                    ],
                  ),
                ),
              ),

              // المنتجات المرتبطة
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'منتجات مرتبطة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 280,
                        child: _buildRelatedProducts(),
                      ),
                    ],
                  ),
                ),
              ),

              // مسافة في الأسفل
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PhotoViewGallery.builder(
            scrollPhysics: const ClampingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.white),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withAlpha(
                          _currentImageIndex == entry.key ? 229 : 102,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(Product product) {
    final regularPrice = CurrencyFormatter.format(product.regularPrice);
    final salePrice = CurrencyFormatter.format(product.salePrice);
    
    return Row(
      children: [
        if (product.onSale) ...[
          Text(
            salePrice,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            regularPrice,
            style: GoogleFonts.cairo(
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ] else
          Text(
            regularPrice,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildVariationOptions(Product product) {
    return FutureBuilder<List<dynamic>>(
      future: _variationsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: product.attributes
              .where((attr) => attr.variation)
              .map((attr) => _buildAttributeSelector(attr))
              .toList(),
        );
      },
    );
  }

  Widget _buildAttributeSelector(ProductAttribute attribute) {
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
        Wrap(
          spacing: 8,
          children: attribute.options.map((option) {
            final isSelected = selectedAttributes[attribute.name] == option;
            
            return ChoiceChip(
              label: Text(
                option,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedAttributes[attribute.name] = option;
                  } else {
                    selectedAttributes.remove(attribute.name);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockStatus(Product product) {
    return Row(
      children: [
        Icon(
          product.inStock ? Icons.check_circle : Icons.remove_circle,
          color: product.inStock ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          product.inStock ? 'متوفر' : 'غير متوفر',
          style: GoogleFonts.cairo(
            color: product.inStock ? Colors.green : Colors.red,
          ),
        ),
        if (product.inStock && product.stockQuantity > 0) ...[
          const SizedBox(width: 8),
          Text(
            '(${product.stockQuantity} قطعة متبقية)',
            style: GoogleFonts.cairo(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'الكمية:',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 1
              ? () => setState(() => quantity--)
              : null,
        ),
        Text(
          quantity.toString(),
          style: GoogleFonts.cairo(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => quantity++),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Product product) {
    final bool canAddToCart = product.inStock &&
        (product.type == 'simple' ||
            (product.type == 'variable' &&
                selectedAttributes.length == product.attributes.length));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAddToCart
            ? () {
                // TODO: إضافة للسلة
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'إضافة للسلة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return FutureBuilder<List<dynamic>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ في تحميل المراجعات',
              style: GoogleFonts.cairo(),
            ),
          );
        }

        final reviews = snapshot.data!;
        if (reviews.isEmpty) {
          return Center(
            child: Text(
              'لا توجد مراجعات بعد',
              style: GoogleFonts.cairo(),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['reviewer'] ?? '',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: List.generate(
                            review['rating'] ?? 0,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['review'] ?? '',
                      style: GoogleFonts.cairo(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRelatedProducts() {
    return FutureBuilder<List<dynamic>>(
      future: _relatedProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'حدث خطأ في تحميل المنتجات المرتبطة',
              style: GoogleFonts.cairo(),
            ),
          );
        }

        final relatedProducts = snapshot.data ?? [];

        if (relatedProducts.isEmpty) return const SizedBox();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: relatedProducts.length,
          itemBuilder: (context, index) {
            final product = relatedProducts[index];
            return Card(
              margin: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.images.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: product.images.first,
                        height: 120,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(product.price),
                            style: GoogleFonts.cairo(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
