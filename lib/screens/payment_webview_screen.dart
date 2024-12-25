import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final Function(bool) onPaymentComplete;

  const PaymentWebViewScreen({
    Key? key,
    required this.url,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
            });
            _updateBackButtonState();
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);
            _updateBackButtonState();
            
            // تحسين عرض صفحة الدفع
            await _controller.runJavaScript('''
              // إخفاء العناصر غير الضرورية
              document.querySelector('header')?.remove();
              document.querySelector('footer')?.remove();
              document.querySelector('nav')?.remove();
              document.querySelector('.site-header')?.remove();
              document.querySelector('.site-footer')?.remove();
              document.querySelector('#masthead')?.remove();
              document.querySelector('#colophon')?.remove();
              
              // تحسين عرض نموذج الدفع
              var checkoutForm = document.querySelector('.woocommerce-checkout, #order_review');
              if (checkoutForm) {
                checkoutForm.style.padding = '16px';
                checkoutForm.style.margin = '0';
                checkoutForm.style.maxWidth = '100%';
              }

              // تحسين عرض طرق الدفع
              var paymentMethods = document.querySelector('#payment');
              if (paymentMethods) {
                paymentMethods.style.marginTop = '16px';
                paymentMethods.style.padding = '16px';
                paymentMethods.style.backgroundColor = '#f8f9fa';
                paymentMethods.style.borderRadius = '8px';
                paymentMethods.style.border = '1px solid #dee2e6';
              }

              // تحسين عرض قائمة طرق الدفع
              var paymentMethodsList = document.querySelectorAll('ul.payment_methods li');
              paymentMethodsList.forEach(method => {
                method.style.padding = '12px';
                method.style.marginBottom = '8px';
                method.style.border = '1px solid #dee2e6';
                method.style.borderRadius = '4px';
                method.style.backgroundColor = '#ffffff';
                method.style.cursor = 'pointer';
                method.style.transition = 'all 0.2s ease';
              });

              // إضافة تأثير عند النقر على طرق الدفع
              paymentMethodsList.forEach(method => {
                method.addEventListener('click', () => {
                  method.style.backgroundColor = '#f8f9fa';
                  method.style.transform = 'scale(0.98)';
                });
              });

              // تحسين عرض طرق الشحن
              var shippingMethods = document.querySelector('#shipping_method');
              if (shippingMethods) {
                shippingMethods.style.marginTop = '16px';
                shippingMethods.style.padding = '16px';
                shippingMethods.style.backgroundColor = '#f8f9fa';
                shippingMethods.style.borderRadius = '8px';
                shippingMethods.style.border = '1px solid #dee2e6';
              }

              // تحسين عرض زر إتمام الطلب
              var placeOrderButton = document.querySelector('#place_order');
              if (placeOrderButton) {
                placeOrderButton.style.width = '100%';
                placeOrderButton.style.padding = '16px';
                placeOrderButton.style.marginTop = '16px';
                placeOrderButton.style.backgroundColor = '#2c3e50';
                placeOrderButton.style.color = 'white';
                placeOrderButton.style.border = 'none';
                placeOrderButton.style.borderRadius = '8px';
                placeOrderButton.style.fontSize = '16px';
                placeOrderButton.style.cursor = 'pointer';
                placeOrderButton.style.display = 'block';
                placeOrderButton.style.transition = 'all 0.2s ease';
              }

              // إضافة تأثير عند تحريك المؤشر فوق الزر
              if (placeOrderButton) {
                placeOrderButton.addEventListener('mouseover', () => {
                  placeOrderButton.style.backgroundColor = '#34495e';
                  placeOrderButton.style.transform = 'translateY(-1px)';
                });
                placeOrderButton.addEventListener('mouseout', () => {
                  placeOrderButton.style.backgroundColor = '#2c3e50';
                  placeOrderButton.style.transform = 'translateY(0)';
                });
              }

              // تحسين عرض ملخص الطلب
              var orderReview = document.querySelector('.woocommerce-checkout-review-order-table');
              if (orderReview) {
                orderReview.style.width = '100%';
                orderReview.style.marginBottom = '16px';
                orderReview.style.borderCollapse = 'collapse';
                orderReview.style.backgroundColor = '#ffffff';
                orderReview.style.borderRadius = '8px';
                orderReview.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
              }

              // تحسين عرض الأقسام
              var sections = document.querySelectorAll('.woocommerce-checkout-review-order-table th, .woocommerce-checkout-review-order-table td');
              sections.forEach(section => {
                section.style.padding = '12px';
                section.style.borderBottom = '1px solid #dee2e6';
              });

              // إضافة تأثيرات التحميل
              document.body.style.opacity = '0';
              document.body.style.transition = 'opacity 0.3s ease';
              setTimeout(() => {
                document.body.style.opacity = '1';
              }, 100);
            ''');

            // التحقق من اكتمال الدفع
            if (url.contains('order-received') || url.contains('thank-you')) {
              widget.onPaymentComplete(true);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _updateBackButtonState() async {
    final canGoBack = await _controller.canGoBack();
    if (mounted && canGoBack != _canGoBack) {
      setState(() {
        _canGoBack = canGoBack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'الدفع',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (_isLoading)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: _loadingProgress,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
