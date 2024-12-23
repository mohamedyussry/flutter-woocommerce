import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/category_products_screen.dart';
import '../providers/categories_provider.dart';
import '../models/category.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.face_retouching_natural,
      Icons.cut,
      Icons.brush,
      Icons.spa,
      Icons.accessibility_new,
      Icons.man,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        if (categoriesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoriesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(categoriesProvider.error!),
                ElevatedButton(
                  onPressed: () => categoriesProvider.fetchCategories(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final categories = categoriesProvider.categories;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'الفئات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(index).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: category.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      category.image!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    _getCategoryIcon(index),
                                    color: _getCategoryColor(index),
                                    size: 32,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
