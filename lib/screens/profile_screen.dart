import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        final user = _authService.currentUser.value;
        if (user != null) {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _addressController.text = user.address;
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث البيانات بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _authService.currentUser,
        builder: (context, user, child) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'يرجى تسجيل الدخول أولاً',
                    style: GoogleFonts.cairo(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                    style: GoogleFonts.cairo(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                    style: GoogleFonts.cairo(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@')) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    enabled: _isEditing,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      labelStyle: GoogleFonts.cairo(),
                      border: const OutlineInputBorder(),
                    ),
                    style: GoogleFonts.cairo(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال العنوان';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'حفظ التغييرات',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrdersScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'طلباتي',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _authService.logout();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'تسجيل الخروج',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
