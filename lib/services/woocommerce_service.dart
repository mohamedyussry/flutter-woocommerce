import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';

class WooCommerceService {
  final String _baseUrl;
  final String _consumerKey;
  final String _consumerSecret;
  final http.Client _client;

  WooCommerceService()
      : _baseUrl = dotenv.env['WOOCOMMERCE_URL'] ?? '',
        _consumerKey = dotenv.env['WOOCOMMERCE_CONSUMER_KEY'] ?? '',
        _consumerSecret = dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'] ?? '',
        _client = http.Client() {
    debugPrint('🔄 WooCommerce Service Initialized');
    debugPrint('🌐 Base URL: $_baseUrl');
    debugPrint('🔑 Consumer Key: $_consumerKey');
  }

  Uri _buildUri(String endpoint, Map<String, dynamic> queryParameters) {
    final uri = Uri.parse('$_baseUrl/wp-json/wc/v3$endpoint');
    final Map<String, dynamic> params = {
      'consumer_key': _consumerKey,
      'consumer_secret': _consumerSecret,
      ...queryParameters,
    };

    return uri.replace(queryParameters: params.map((key, value) => MapEntry(key, value.toString())));
  }

  Future<T> _get<T>(
    String endpoint,
    Map<String, dynamic> queryParameters,
    T Function(dynamic json) parser,
  ) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      debugPrint('🌐 Making GET request to: $uri');

      final response = await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        debugPrint('📊 Response type: ${decodedJson.runtimeType}');

        if (decodedJson is List) {
          debugPrint('📊 List length: ${decodedJson.length}');
          if (decodedJson.isNotEmpty) {
            debugPrint('📊 First item type: ${decodedJson.first.runtimeType}');
            final firstItem = decodedJson.first;
            if (firstItem is Map<String, dynamic>) {
              debugPrint('📊 Image URLs in first item: ${firstItem['images']?.map((img) => img['src'])}');
            }
          }
        }

        try {
          return parser(decodedJson);
        } catch (e, stack) {
          debugPrint('❌ Error parsing data: $e');
          debugPrint('📋 Stack trace: $stack');
          rethrow;
        }
      } else {
        debugPrint('❌ Error Response Body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('❌ Error in _get: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
    String orderBy = 'date',
    String order = 'desc',
  }) async {
    final queryParameters = {
      'page': page,
      'per_page': perPage,
      'orderby': orderBy,
      'order': order,
    };

    if (categoryId != null) {
      queryParameters['category'] = categoryId;
    }

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return _get<List<Product>>(
      '/products',
      queryParameters,
      (json) => (json as List).map((item) {
        try {
          final product = Product.fromJson(item as Map<String, dynamic>);
          debugPrint('✅ Successfully parsed product: ${product.id} - ${product.name}');
          if (product.images.isNotEmpty) {
            debugPrint('🖼️ First image URL: ${product.images.first.src}');
          }
          return product;
        } catch (e, stack) {
          debugPrint('❌ Error parsing product: $e');
          debugPrint('📋 Stack trace: $stack');
          rethrow;
        }
      }).toList(),
    );
  }

  void dispose() {
    _client.close();
  }
}
