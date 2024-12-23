import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/categories_provider.dart';
import '../models/category.dart';
import '../screens/category_products_screen.dart';

class CategorySlider extends StatefulWidget {
  const CategorySlider({super.key});

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Category> _getRandomCategories(List<Category> categories) {
    // فلتر الأقسام التي لها صور فقط
    final categoriesWithImages = categories.where((cat) => cat.image.isNotEmpty).toList();
    
    // إذا كان عدد الأقسام أقل من 5، نرجع كل الأقسام
    if (categoriesWithImages.length <= 5) return categoriesWithImages;
    
    // اختيار 5 أقسام عشوائية
    final random = Random();
    final selectedCategories = <Category>[];
    final tempList = List<Category>.from(categoriesWithImages);
    
    while (selectedCategories.length < 5 && tempList.isNotEmpty) {
      final index = random.nextInt(tempList.length);
      selectedCategories.add(tempList[index]);
      tempList.removeAt(index);
    }
    
    return selectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        if (categoriesProvider.isLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (categoriesProvider.error != null) {
          return const SizedBox.shrink();
        }

        final categories = _getRandomCategories(categoriesProvider.categories);
        
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: categories.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            categoryId: category.id,
                            categoryName: category.name,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              category.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (category.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      category.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                categories.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
