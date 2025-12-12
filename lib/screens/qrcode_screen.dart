import 'package:flutter/material.dart';
import 'package:minhhai/qrcode_helper.dart';
import 'package:minhhai/auth_service.dart';

class QRCodeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const QRCodeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  late String qrData;
  late List<int> qrImageData;

  @override
  void initState() {
    super.initState();
    _generateQR();
    _recordShare();
  }

  void _generateQR() {
    qrData = QRCodeHelper.generateQRData(widget.userData);
  }

  Future<void> _recordShare() async {
    if (AuthService.currentUser != null) {
      await QRCodeHelper.saveQRShare(AuthService.currentUser!);
    }
  }

  Future<void> _downloadQR() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ QR được tạo sẵn để chia sẻ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔗 Chia sẻ Profile'),
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
              // 📋 Thông tin người dùng
              // ================================
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "👤 ${widget.userData['username']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "📧 ${widget.userData['email']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "📱 ${widget.userData['phone']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================================
              // 🔲 QR Code
              // ================================
              const Text(
                "🔲 Mã QR Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // QR Code Placeholder (Trong thực tế dùng qr_flutter package)
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 100,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "QR Code\n(qr_flutter needed)",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR Data Text
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        qrData,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================================
              // 🔗 Hành động chia sẻ
              // ================================
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Đã sao chép QR data'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text("📋 Sao chép dữ liệu"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _downloadQR,
                      icon: const Icon(Icons.download),
                      label: const Text("⬇ Tải QR"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Chia sẻ profile'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("📤 Chia sẻ"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================================
              // 📊 Thống kê chia sẻ
              // ================================
              FutureBuilder<List<DateTime>>(
                future: QRCodeHelper.getQRShareHistory(
                  widget.userData['username'],
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final shareCount = snapshot.data?.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                "📊 Thống kê chia sẻ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Lần chia sẻ: $shareCount",
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (shareCount > 0) ...[
                            const SizedBox(height: 5),
                            Text(
                              "Lần cuối: ${snapshot.data!.first.toString().split('.')[0]}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),

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
                        Icon(Icons.help_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "💡 Cách dùng",
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
                      "1. Bấm '📋 Sao chép' để copy mã QR\n"
                      "2. Chia sẻ với bạn bè qua SMS/Email\n"
                      "3. Bạn bè scan QR để xem profile\n"
                      "4. Hoặc bấm '📤 Chia sẻ' dùng ứng dụng khác",
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
}
