import 'package:flutter/material.dart';
import '../qrcode_helper.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final TextEditingController _qrController = TextEditingController();
  Map<String, dynamic>? scannedProfile;
  bool _isProcessing = false;

  void _processQRData(String data) {
    setState(() => _isProcessing = true);

    // Simulate QR processing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final profile = QRCodeHelper.parseQRData(data);

      if (profile != null) {
        setState(() {
          scannedProfile = profile;
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Quét QR thành công'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ QR không hợp lệ'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _clearResult() {
    setState(() {
      scannedProfile = null;
      _qrController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ================================
              // 📷 Camera Icon
              // ================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Quét mã QR profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Sử dụng camera để quét hoặc dán dữ liệu QR",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // ================================
              // 📝 Paste QR Data
              // ================================
              TextField(
                controller: _qrController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Dán dữ liệu QR ở đây",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 15),

              // ================================
              // 🔍 Quét Button
              // ================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          if (_qrController.text.isNotEmpty) {
                            _processQRData(_qrController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Vui lòng dán dữ liệu QR'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.search),
                  label: const Text("Quét QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================================
              // ✅ Kết quả quét
              // ================================
              if (scannedProfile != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "Quét thành công",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProfileInfo(
                        "Username",
                        scannedProfile!['username'].toString(),
                      ),
                      _buildProfileInfo(
                        "Email",
                        scannedProfile!['email'].toString(),
                      ),
                      _buildProfileInfo(
                        "Phone",
                        scannedProfile!['phone'].toString(),
                      ),
                      _buildProfileInfo(
                        "Created",
                        scannedProfile!['created_at'].toString(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _clearResult,
                            icon: const Icon(Icons.clear),
                            label: const Text("Xóa"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📋 Đã lưu profile'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.save),
                            label: const Text("Lưu"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (_isProcessing) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text("Đang xử lý..."),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ================================
              // 💡 Hướng dẫn
              // ================================
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "ℹ️ Hướng dẫn",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "1. Bấm camera để quét QR profile\n"
                      "2. Hoặc sao chép dữ liệu QR rồi dán vào\n"
                      "3. Bấm '🔍 Quét QR' để xử lý\n"
                      "4. Xem thông tin profile của người khác\n"
                      "5. Bấm 'Lưu' để lưu vào danh bạ",
                      style: TextStyle(fontSize: 13, height: 1.8),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }
}
