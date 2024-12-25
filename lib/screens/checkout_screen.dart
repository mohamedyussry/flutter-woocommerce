import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import 'login_screen.dart';
import 'payment_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({
    super.key, 
    required this.total,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  final _wooCommerceService = WooCommerceService();
  
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _shippingMethods = [];
  String? _selectedPaymentMethod;
  String? _selectedShippingMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentAndShippingMethods();
  }

  Future<void> _loadPaymentAndShippingMethods() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final paymentMethods = await _wooCommerceService.getPaymentGateways();
      final shippingMethods = await _wooCommerceService.getShippingMethods();
      
      if (!mounted) return;
      
      setState(() {
        _paymentMethods = paymentMethods.where((method) => method['enabled'] == true).toList();
        _shippingMethods = shippingMethods.where((method) => method['enabled'] == true).toList();
        
        if (_paymentMethods.isNotEmpty) {
          _selectedPaymentMethod = _paymentMethods.first['id'];
        }
        if (_shippingMethods.isNotEmpty) {
          _selectedShippingMethod = _shippingMethods.first['id'];
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ في تحميل طرق الدفع والشحن',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrder() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;
    
    debugPrint('🔍 Selected payment method: $_selectedPaymentMethod');
    debugPrint('🔍 Selected shipping method: $_selectedShippingMethod');
    
    if (_selectedPaymentMethod == null || 
        _selectedShippingMethod == null || 
        _selectedPaymentMethod!.isEmpty || 
        _selectedShippingMethod!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء اختيار طريقة الدفع والشحن',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final selectedPaymentMethod = _paymentMethods.firstWhere(
        (method) => method['id'] == _selectedPaymentMethod,
        orElse: () => throw Exception('Payment method not found'),
      );
      debugPrint('💳 Selected payment method details: $selectedPaymentMethod');

      // تنظيف وتنسيق البيانات
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      final orderData = {
        'payment_method': selectedPaymentMethod['id'],
        'payment_method_title': selectedPaymentMethod['title'],
        'status': 'pending',
        'shipping_method': _selectedShippingMethod,
        'billing': {
          'first_name': name,
          'last_name': '',
          'email': email,
          'phone': phone,
          'address_1': address,
          'address_2': '',
          'city': '',
          'state': '',
          'postcode': '',
          'country': 'AE'
        },
        'shipping': {
          'first_name': name,
          'last_name': '',
          'address_1': address,
          'address_2': '',
          'city': '',
          'state': '',
          'postcode': '',
          'country': 'AE'
        },
        'line_items': widget.cartItems.map((item) => {
          'product_id': item['id'],
          'quantity': item['quantity'],
        }).toList(),
      };

      debugPrint('📦 Sending order data: $orderData');
      final response = await _wooCommerceService.createOrder(orderData);
      debugPrint('✅ Order created: $response');

      if (!mounted) return;

      // الحصول على رابط الدفع
      final paymentUrl = await _wooCommerceService.getPaymentUrl(response);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      // فتح شاشة الدفع
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            onPaymentSuccess: () {
              // العودة إلى الشاشة الرئيسية عند اكتمال الدفع
              Navigator.popUntil(context, (route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم الدفع بنجاح',
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ في إرسال الطلب',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                size: 64,
                color: Colors.green.shade200,
              ),
              const SizedBox(height: 24),
              Text(
                'يجب تسجيل الدخول لإتمام عملية الشراء',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الدفع',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentAndShippingMethods,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات التوصيل',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        labelStyle: GoogleFonts.cairo(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'example@domain.com',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                        hintStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        // التحقق من صحة تنسيق البريد الإلكتروني
                        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        labelStyle: GoogleFonts.cairo(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'العنوان',
                        labelStyle: GoogleFonts.cairo(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العنوان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'طريقة الشحن',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_shippingMethods.isEmpty)
                      Column(
                        children: [
                          Text(
                            'لا توجد طرق شحن متاحة',
                            style: GoogleFonts.cairo(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: _loadPaymentAndShippingMethods,
                            child: Text(
                              'إعادة تحميل طرق الشحن',
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: _shippingMethods.map((method) {
                          debugPrint('🚚 Rendering shipping method: ${method['id']} - ${method['title']}');
                          return RadioListTile(
                            title: Text(
                              method['title'],
                              style: GoogleFonts.cairo(),
                            ),
                            subtitle: Text(
                              '${method['description'] ?? ''} - ${method['cost']} درهم',
                              style: GoogleFonts.cairo(),
                            ),
                            value: method['id'],
                            groupValue: _selectedShippingMethod,
                            onChanged: (value) {
                              debugPrint('🚚 Shipping method selected: $value');
                              setState(() {
                                _selectedShippingMethod = value as String;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'طريقة الدفع',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_paymentMethods.isEmpty)
                      Column(
                        children: [
                          Text(
                            'لا توجد طرق دفع متاحة',
                            style: GoogleFonts.cairo(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: _loadPaymentAndShippingMethods,
                            child: Text(
                              'إعادة تحميل طرق الدفع',
                              style: GoogleFonts.cairo(),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: _paymentMethods.map((method) {
                          debugPrint('💳 Rendering payment method: ${method['id']} - ${method['title']}');
                          return RadioListTile(
                            title: Text(
                              method['title'],
                              style: GoogleFonts.cairo(),
                            ),
                            subtitle: Text(
                              method['description'] ?? '',
                              style: GoogleFonts.cairo(),
                            ),
                            value: method['id'],
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              debugPrint('💳 Payment method selected: $value');
                              setState(() {
                                _selectedPaymentMethod = value as String;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المجموع',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.total.toStringAsFixed(2)} درهم',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isLoading ? 'جاري المعالجة...' : 'تأكيد الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
