import 'package:flutter/material.dart';
import 'player_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // =============================
  // 📌 Danh sách nhạc của bạn
  // =============================
  final List<Map<String, String>> _songs = const [
    // ★★★ Thêm tất cả bài hát bạn đã gửi ★★★
    {"title": "Bài Ca Người Giáo Viên Nhân Dân", "file": "BaiCaNguoiGiaoVienNhanDan-TrongTan-2852412_hq.mp3"},
    {"title": "Bài Ca Trên Núi", "file": "BaiCaTrenNui-TrongTan-2159468_hq (1).mp3"},
    {"title": "Biển Tình", "file": "BienTinh-AnhTho-2868429_hq.mp3"},
    {"title": "Buồn Tan Thu", "file": "BuonTanThu-AnhTho-2985977_hq (1).mp3"},
    {"title": "Buông Áo Em Ra", "file": "BuongAoEmRa-BuiLeMan-11117854_hq.mp3"},
    {"title": "Ca Dao Em Và Tôi", "file": "CaDaoEmVaToi-ThanhHoaNSND-8865651_hq.mp3"},
    {"title": "Câu Ca Em Hát Phú Thọ Quê Mình", "file": "CauCaEmHatPhuThoQueMinh-HuongGia_s52e.mp3"},
    {"title": "Cầu Dời Cầu Chờ", "file": "CauDoiCauCho-BuiLeMan-11117857_hq.mp3"},
    {"title": "Cô Gái Mở Đường", "file": "CoGaiMoDuong-AnhTho-4277836.mp3"},
    {"title": "Cô Hàng Nước", "file": "CoHangNuoc-NSNDThuHien_33nt8.mp3"},

    // ★★★ 3 bài cũ trong demo ★★★
    {"title": "Gánh mẹ", "file": "song1.m4a"},
    {"title": "Thành Phố Buồn", "file": "song2.m4a"},
    {"title": "Thái Hoàng", "file": "song3.mp3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2DE2), // tím đậm
              Color(0xFFDA22FF), // hồng tím
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================
              // 🎵 TIÊU ĐỀ & 🔲 QR Scanner
              // =============================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.library_music, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text(
                          "Playlist của bạn",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                      tooltip: "Quét QR Profile",
                    ),
                  ],
                ),
              ),

              // =============================
              // 📃 DANH SÁCH BÀI HÁT
              // =============================
              Expanded(
                child: ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              songList: _songs,
                              currentIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // =============================
                            // 🖼 Ảnh từng bài hát
                            // =============================
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/images/dau.jpg",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 15),

                            // =============================
                            // 🎧 TÊN BÀI + FILE
                            // =============================
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song["title"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song["file"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // =============================
                            // ▶ NÚT PLAY
                            // =============================
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration:
                                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Color(0xFF8E2DE2),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
