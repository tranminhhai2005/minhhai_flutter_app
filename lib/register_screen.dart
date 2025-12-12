import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:minhhai/auth_service.dart';
import 'package:minhhai/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  // 📸 CHỌN ẢNH
  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final saved = await File(file.path).copy("${appDir.path}/${file.name}");

    setState(() => _avatarImage = saved);
  }

  // 🔐 ĐĂNG KÝ
  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        pass.isEmpty ||
        confirm.isEmpty) {
      _show("⚠️ Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      _show("❌ Email không hợp lệ!");
      return;
    }

    if (phone.length < 9) {
      _show("❌ Số điện thoại không hợp lệ!");
      return;
    }

    if (pass != confirm) {
      _show("❌ Mật khẩu xác nhận không khớp!");
      return;
    }

    final ok = await AuthService.register(
      username,
      pass,
      email,
      phone,
    );

    if (!ok) {
      _show("⚠️ Tài khoản $username đã tồn tại!");
      return;
    }

    _show("✅ Đăng ký thành công!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ⭐ Hiển thị Snackbar
  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  InputDecoration _input(String text, IconData icon) {
    return InputDecoration(
      labelText: text,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/background.jpg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.55)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/dau.jpg",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Đăng ký tài khoản",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          _avatarImage != null ? FileImage(_avatarImage!) : null,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: _avatarImage == null
                          ? const Icon(Icons.add_a_photo,
                              size: 38, color: Colors.deepPurple)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 25),

                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Tên đăng nhập", Icons.person),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Email", Icons.email),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: _input("Số điện thoại", Icons.phone),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Mật khẩu", Icons.lock),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input("Xác nhận mật khẩu", Icons.lock_reset),
                  ),
                  const SizedBox(height: 35),

                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Đăng ký",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "🔙 Đã có tài khoản? Đăng nhập ngay",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
