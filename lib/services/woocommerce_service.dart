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
    final baseUrl = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final uri = Uri.parse('$baseUrl/wp-json/wc/v3$endpoint');
    final Map<String, dynamic> params = {
      'consumer_key': _consumerKey,
      'consumer_secret': _consumerSecret,
      ...queryParameters,
    };

    debugPrint('🔗 Building URI for endpoint: $endpoint');
    final finalUri = uri.replace(queryParameters: params.map((key, value) => MapEntry(key, value.toString())));
    debugPrint('🌐 Final URI: $finalUri');
    return finalUri;
  }

  Future<T> _get<T>(
    String endpoint,
    Map<String, dynamic> queryParameters,
    T Function(dynamic json) parser,
  ) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      final response = await _client.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('📥 Response status code: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        return parser(decodedJson);
      }

      debugPrint('❌ Error Response Body: ${response.body}');
      throw Exception('Failed to load data: ${response.statusCode} - ${response.body}');
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

  Future<List<Map<String, dynamic>>> getPaymentGateways() async {
    try {
      debugPrint('🔄 Fetching payment gateways...');
      final uri = Uri.parse('${_baseUrl}wp-json/wc/v3/payment_gateways').replace(
        queryParameters: {
          'consumer_key': _consumerKey,
          'consumer_secret': _consumerSecret,
          'force': 'true', // تجاهل التخزين المؤقت
        },
      );
      debugPrint('🌐 Request URL: $uri');

      final response = await _client.get(uri);
      debugPrint('📥 Response status code: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final paymentMethods = data.map((item) => {
          'id': item['id'] as String? ?? '',
          'title': item['title'] as String? ?? '',
          'description': item['description'] as String? ?? '',
          'enabled': item['enabled'] as bool? ?? false,
          'method_title': item['method_title'] as String? ?? '',
          'method_description': item['method_description'] as String? ?? '',
        }).toList();

        // فلترة طرق الدفع المفعلة فقط
        final enabledMethods = paymentMethods.where((method) => method['enabled'] == true).toList();
        debugPrint('💳 Available payment methods: $enabledMethods');
        return enabledMethods;
      }
      
      debugPrint('❌ Error Response: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching payment gateways: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getShippingMethods() async {
    try {
      debugPrint('🔄 Fetching shipping methods...');
      
      // أولاً، نحصل على مناطق الشحن
      final zonesUri = Uri.parse('${_baseUrl}wp-json/wc/v3/shipping/zones').replace(
        queryParameters: {
          'consumer_key': _consumerKey,
          'consumer_secret': _consumerSecret,
        },
      );
      debugPrint('🌐 Fetching shipping zones: $zonesUri');
      
      final zonesResponse = await _client.get(zonesUri);
      debugPrint('📥 Zones response status: ${zonesResponse.statusCode}');
      debugPrint('📦 Zones response body: ${zonesResponse.body}');
      
      if (zonesResponse.statusCode == 200) {
        final List<dynamic> zones = json.decode(zonesResponse.body);
        List<Map<String, dynamic>> allShippingMethods = [];
        
        // إضافة المنطقة 0 (Rest of the World)
        zones.add({'id': 0, 'name': 'Rest of the World'});
        
        // البحث في جميع المناطق
        for (var zone in zones) {
          final zoneId = zone['id'];
          debugPrint('🔍 Checking zone $zoneId: ${zone['name']}');
          
          final methodsUri = Uri.parse('${_baseUrl}wp-json/wc/v3/shipping/zones/$zoneId/methods').replace(
            queryParameters: {
              'consumer_key': _consumerKey,
              'consumer_secret': _consumerSecret,
            },
          );
          
          final methodsResponse = await _client.get(methodsUri);
          if (methodsResponse.statusCode == 200) {
            final List<dynamic> methods = json.decode(methodsResponse.body);
            final zoneMethods = methods.map((item) => {
              'id': item['id'].toString(),
              'title': '${item['title']} (${zone['name']})',
              'description': item['description'] as String? ?? '',
              'enabled': item['enabled'] as bool? ?? false,
              'method_id': item['method_id'] as String? ?? '',
              'cost': (item['settings']?['cost']?['value'] as String? ?? '0').replaceAll(RegExp(r'[^\d.]'), ''),
              'zone_id': zoneId,
              'zone_name': zone['name'],
            }).where((method) => method['enabled'] == true).toList();
            
            allShippingMethods.addAll(zoneMethods);
          }
        }
        
        debugPrint('🚚 All available shipping methods: $allShippingMethods');
        return allShippingMethods;
      }
      
      debugPrint('❌ Error fetching shipping methods');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching shipping methods: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final uri = _buildUri('/orders', {});
      debugPrint('🌐 Creating order with data: $orderData');
      
      final response = await _client.post(
        uri,
        body: json.encode(orderData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        debugPrint('✅ Order created successfully: ${response.body}');
        return responseData;
      }
      
      debugPrint('❌ Error creating order: ${response.body}');
      throw Exception('Failed to create order: ${response.body}');
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      rethrow;
    }
  }

  Future<String?> getCheckoutUrl({
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> customerData,
  }) async {
    try {
      // إنشاء الطلب مع بيانات العميل
      final orderUri = Uri.parse('$_baseUrl/wp-json/wc/v3/orders');
      final orderResponse = await _client.post(
        orderUri,
        body: json.encode({
          'status': 'pending',
          'billing': customerData['billing'],
          'shipping': customerData['shipping'],
          'line_items': cartItems.map((item) => {
            'product_id': item['id'],
            'quantity': item['quantity'],
          }).toList(),
          'customer_note': customerData['customer_note'] ?? '',
          'customer_id': customerData['customer_id'] ?? 0,
        }),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'))}',
          'Content-Type': 'application/json',
        },
      );

      if (orderResponse.statusCode == 201) {
        final orderData = json.decode(orderResponse.body);
        final orderId = orderData['id'];
        final orderKey = orderData['order_key'];
        
        // إنشاء رابط صفحة الدفع
        final checkoutUrl = '$_baseUrl/checkout/order-pay/$orderId/?key=$orderKey&pay_for_order=true';
        debugPrint('Checkout URL: $checkoutUrl');
        return checkoutUrl;
      } else {
        debugPrint('Failed to create order: ${orderResponse.statusCode} - ${orderResponse.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error creating checkout URL: $e');
      return null;
    }
  }

  Future<String?> getPaymentUrl(Map<String, dynamic> orderData) async {
    try {
      final orderId = orderData['id'];
      final orderKey = orderData['order_key'];
      return '$_baseUrl/checkout/order-pay/$orderId?pay_for_order=true&key=$orderKey';
    } catch (e) {
      debugPrint('Error getting payment URL: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getShippingZones() async {
    try {
      final uri = _buildUri('/shipping/zones', {});
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load shipping zones');
    } catch (e) {
      debugPrint('❌ Error fetching shipping zones: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
