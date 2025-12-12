import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:minhhai/auth_service.dart';
import 'package:minhhai/main.dart' show globalThemeProvider;
import 'package:minhhai/screens/qrcode_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? currentUser;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadAvatar();
  }

  // ==========================================
  // 🔹 Hàm tính thời gian sử dụng (Format: X năm X tháng X ngày HH:MM:SS)
  // ==========================================
  String calculateUsedTime(DateTime created) {
    final now = DateTime.now();
    final diff = now.difference(created);

    int years = diff.inDays ~/ 365;
    int months = (diff.inDays % 365) ~/ 30;
    int days = diff.inDays % 30;
    int hours = diff.inHours % 24;
    int minutes = diff.inMinutes % 60;
    int seconds = diff.inSeconds % 60;

    return "$years năm $months tháng $days ngày "
        "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  // ==========================================
  // 🔹 Lấy thông tin user
  // ==========================================
  Future<void> _loadUserInfo() async {
    final users = await AuthService.getAllUsers();
    String? current = AuthService.currentUser;

    if (current != null) {
      final user = users.firstWhere(
        (u) => u["username"] == current,
        orElse: () => {},
      );

      setState(() => currentUser = user);
    }
  }

  // ==========================================
  // 🔹 Avatar Logic
  // ==========================================
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final temp = File(picked.path);
      final dir = await getApplicationDocumentsDirectory();
      final saved = await temp.copy("${dir.path}/${picked.name}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("avatar_path", saved.path);

      setState(() => _avatarImage = saved);
    }
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("avatar_path");
    if (path != null && File(path).existsSync()) {
      setState(() => _avatarImage = File(path));
    }
  }

  Future<void> _deleteAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("avatar_path");
    setState(() => _avatarImage = null);
  }

  // ==========================================
  // 🔥 Chỉnh sửa thông tin
  // ==========================================
  void _editProfile() {
    final emailCtrl = TextEditingController(text: currentUser?['email']);
    final phoneCtrl = TextEditingController(text: currentUser?['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chỉnh sửa thông tin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email mới"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Số điện thoại mới"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Lưu"),
            onPressed: () async {
              await AuthService.updateUser(
                currentUser!['username'],
                {
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                },
              );
              _loadUserInfo();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✔ Cập nhật thành công")),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 Xuất PDF (CÓ ẢNH + ĐỊNH DẠNG THỜI GIAN)
  // ==========================================
  Future<void> _exportPDF() async {
    if (currentUser == null) return;

    final pdf = pw.Document();

    // Load Font
    final font = pw.Font.ttf(
        await rootBundle.load("assets/fonts/roboto/Roboto-Regular.ttf"));
    final bold = pw.Font.ttf(
        await rootBundle.load("assets/fonts/roboto/Roboto-Bold.ttf"));

    // 1. Xử lý Ảnh đại diện cho PDF
    pw.MemoryImage? profileImage;
    if (_avatarImage != null && _avatarImage!.existsSync()) {
      final imageBytes = await _avatarImage!.readAsBytes();
      profileImage = pw.MemoryImage(imageBytes);
    }

    // 2. Xử lý Thời gian tạo
    String formattedTime = "0 năm 0 tháng 0 ngày 00:00:00";
    if (currentUser!["created_at"] != null) {
      DateTime? created = DateTime.tryParse(currentUser!["created_at"].toString());
      if (created != null) {
        formattedTime = calculateUsedTime(created);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center, // Căn giữa nội dung
            children: [
              // --- ẢNH ĐẠI DIỆN TRONG PDF ---
              if (profileImage != null)
                pw.Container(
                  width: 100,
                  height: 100,
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.ClipOval(
                    child: pw.Image(profileImage, fit: pw.BoxFit.cover),
                  ),
                )
              else
                pw.Container(
                  width: 100,
                  height: 100,
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                    shape: pw.BoxShape.circle,
                  ),
                ),
              // ------------------------------

              pw.Text("THÔNG TIN NGƯỜI DÙNG",
                  style: pw.TextStyle(font: bold, fontSize: 24)),
              pw.SizedBox(height: 30),

              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("👤 Username: ${currentUser!['username']}",
                        style: pw.TextStyle(font: font, fontSize: 16)),
                    pw.SizedBox(height: 10),
                    
                    pw.Text("📧 Email: ${currentUser!['email']}",
                        style: pw.TextStyle(font: font, fontSize: 16)),
                    pw.SizedBox(height: 10),

                    pw.Text("📱 Phone: ${currentUser!['phone']}",
                        style: pw.TextStyle(font: font, fontSize: 16)),
                    pw.SizedBox(height: 10),

                    // Hiển thị thời gian dạng: 0 năm 0 tháng...
                    pw.Text("⏰ Thời gian sử dụng: $formattedTime",
                        style: pw.TextStyle(font: font, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/user_info.pdf");
    await file.writeAsBytes(await pdf.save());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF đã được tạo: ${file.path}")),
      );
    }

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 Thông tin của tôi"),
        backgroundColor: Colors.white,
      ),

      body: currentUser == null
          ? const Center(child: Text("Không tìm thấy thông tin user"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar UI
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : null,
                        child: _avatarImage == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Chọn ảnh đại diện"),
                      ),
                    ),

                    if (_avatarImage != null)
                      Center(
                        child: TextButton.icon(
                          onPressed: _deleteAvatar,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Xóa ảnh đại diện",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Buttons (ĐÃ XÓA NÚT ĐĂNG XUẤT)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit),
                        label: const Text("Sửa thông tin"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Info
                    _buildInfoRow("Username:", "${currentUser!['username']}"),
                    _buildInfoRow("Email:", "${currentUser!['email']}"),
                    _buildInfoRow("Phone:", "${currentUser!['phone']}"),
                    
                    // Hiển thị ngày tạo trong App (Vẫn giữ format cũ hoặc đổi tùy bạn)
                    _buildInfoRow("Created:", "${currentUser!['created_at']}"),

                    const SizedBox(height: 30),

                    // 🌙 Dark Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.brightness_4, size: 24),
                              SizedBox(width: 10),
                              Text(
                                "🌙 Dark Mode",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: globalThemeProvider.isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                globalThemeProvider.toggleTheme();
                              });
                            },
                            activeThumbColor: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 📄 Xuất PDF & 🔲 QR Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _exportPDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("📄 PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QRCodeScreen(userData: currentUser!),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.qr_code_2),
                          label: const Text("🔲 QR"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget phụ để hiển thị dòng thông tin cho gọn code
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
