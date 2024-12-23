import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/category.dart';

class CategoryService {
  final String baseUrl = dotenv.env['WOOCOMMERCE_URL'] ?? '';
  final String consumerKey = dotenv.env['WOOCOMMERCE_CONSUMER_KEY'] ?? '';
  final String consumerSecret = dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'] ?? '';

  Future<List<Category>> getCategories() async {
    try {
      final queryParameters = {
        'per_page': '100',
        'orderby': 'name',
        'order': 'asc',
        'hide_empty': 'false',
      };

      final uri = Uri.parse('${baseUrl}wp-json/wc/v3/products/categories')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) {
          // تعديل البيانات قبل تحويلها إلى كائن Category
          json['image'] = json['image']?['src'] ?? '';
          return Category.fromJson(json);
        }).toList();
      } else {
        print('فشل في جلب الأقسام: ${response.statusCode}');
        print('رسالة الخطأ: ${response.body}');
        throw Exception('فشل في جلب الأقسام: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ أثناء جلب الأقسام: $e');
      throw Exception('حدث خطأ أثناء جلب الأقسام: $e');
    }
  }
}
