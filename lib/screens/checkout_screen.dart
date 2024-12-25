import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
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
  final _notesController = TextEditingController();
  
  bool _saveInfoForNextTime = false;
  bool _isLoading = false;
  
  final WooCommerceService _wooCommerceService = WooCommerceService();

  @override
  void initState() {
    super.initState();
    _loadSavedCustomerInfo();
  }

  Future<void> _loadSavedCustomerInfo() async {
    // TODO: Load saved customer info from SharedPreferences
  }

  Future<void> _saveCustomerInfo() async {
    // TODO: Save customer info to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'معلومات العميل',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
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
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                        hintStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
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
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
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
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'العنوان',
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العنوان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات الطلب (اختياري)',
                        prefixIcon: const Icon(Icons.note),
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.cairo(),
                      ),
                      style: GoogleFonts.cairo(),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text(
                        'حفظ المعلومات للطلبات القادمة',
                        style: GoogleFonts.cairo(),
                      ),
                      value: _saveInfoForNextTime,
                      onChanged: (value) {
                        setState(() => _saveInfoForNextTime = value ?? false);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isLoading ? 'جاري المعالجة...' : 'متابعة الدفع',
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

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // تحضير بيانات العميل
      final customerData = {
        'billing': {
          'first_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address_1': _addressController.text.trim(),
        },
        'shipping': {
          'first_name': _nameController.text.trim(),
          'address_1': _addressController.text.trim(),
        },
        'customer_note': _notesController.text.trim(),
      };

      if (_saveInfoForNextTime) {
        // حفظ بيانات العميل للمرة القادمة
        await _saveCustomerInfo();
      }

      // الانتقال إلى صفحة الدفع في WooCommerce
      final checkoutUrl = await _wooCommerceService.getCheckoutUrl(
        cartItems: widget.cartItems,
        customerData: customerData,
      );

      if (!mounted) return;

      if (checkoutUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              url: checkoutUrl,
              onPaymentComplete: (success) {
                if (success) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إكمال الطلب بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        throw Exception('فشل في الحصول على رابط الدفع');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: ${e.toString()}',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
