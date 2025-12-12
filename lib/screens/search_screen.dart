import 'package:flutter/material.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ================================
  // 📌 Danh sách nhạc với thể loại
  // ================================
  final List<Map<String, dynamic>> _allSongsWithGenre = const [
    {"title": "Bài Ca Người Giáo Viên Nhân Dân", "file": "BaiCaNguoiGiaoVienNhanDan-TrongTan-2852412_hq.mp3", "genre": "Trữ tình"},
    {"title": "Bài Ca Trên Núi", "file": "BaiCaTrenNui-TrongTan-2159468_hq (1).mp3", "genre": "Trữ tình"},
    {"title": "Biển Tình", "file": "BienTinh-AnhTho-2868429_hq.mp3", "genre": "Bolero"},
    {"title": "Buồn Tan Thu", "file": "BuonTanThu-AnhTho-2985977_hq (1).mp3", "genre": "Bolero"},
    {"title": "Buông Áo Em Ra", "file": "BuongAoEmRa-BuiLeMan-11117854_hq.mp3", "genre": "Trữ tình"},
    {"title": "Ca Dao Em Và Tôi", "file": "CaDaoEmVaToi-ThanhHoaNSND-8865651_hq.mp3", "genre": "Bolero"},
    {"title": "Câu Ca Em Hát Phú Thọ Quê Mình", "file": "CauCaEmHatPhuThoQueMinh-HuongGia_s52e.mp3", "genre": "Chill"},
    {"title": "Cầu Dời Cầu Chờ", "file": "CauDoiCauCho-BuiLeMan-11117857_hq.mp3", "genre": "Trữ tình"},
    {"title": "Cô Gái Mở Đường", "file": "CoGaiMoDuong-AnhTho-4277836.mp3", "genre": "Pop"},
    {"title": "Cô Hàng Nước", "file": "CoHangNuoc-NSNDThuHien_33nt8.mp3", "genre": "Bolero"},
    {"title": "Gánh mẹ", "file": "song1.m4a", "genre": "Bolero"},
    {"title": "Thành Phố Buồn", "file": "song2.m4a", "genre": "Pop"},
    {"title": "Thái Hoàng", "file": "song3.mp3", "genre": "Electronic"},
  ];

  // Kết quả tìm kiếm
  List<Map<String, dynamic>> _filteredSongs = [];
  String _selectedGenre = "Tất cả";
  String _searchKeyword = "";

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  // ================================
  // 🔍 Hàm áp dụng bộ lọc
  // ================================
  void _applyFilters() {
    setState(() {
      _filteredSongs = _allSongsWithGenre.where((song) {
        bool matchesGenre = _selectedGenre == "Tất cả" || song["genre"] == _selectedGenre;
        bool matchesKeyword = _searchKeyword.isEmpty ||
            song["title"]!.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            song["file"]!.toLowerCase().contains(_searchKeyword.toLowerCase());
        return matchesGenre && matchesKeyword;
      }).toList();
    });
  }

  // ================================
  // 🔍 Hàm tìm kiếm
  // ================================
  void _searchMusic(String keyword) {
    _searchKeyword = keyword;
    _applyFilters();
  }

  // ================================
  // 🎵 Hàm lọc theo thể loại
  // ================================
  void _filterByGenre(String genre) {
    _selectedGenre = genre;
    _applyFilters();
  }

  // ================================
  // 📌 Thể loại nhạc
  // ================================


  @override
  Widget build(BuildContext context) {
    // Lấy danh sách thể loại duy nhất từ bài hát
    final Set<String> allGenres = {"Tất cả"};
    for (var song in _allSongsWithGenre) {
      allGenres.add(song["genre"]);
    }
    final List<String> genreList = allGenres.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 70, 177),
        title: const Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Khám phá nhạc",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            // 🔍 THANH TÌM KIẾM
            // ================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: _searchMusic,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.blue),
                  hintText: "Tìm kiếm bài hát, tên file...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================================
            // 🎵 BỘ LỌC THỂ LOẠI
            // ================================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genreList.map((genre) {
                  bool isSelected = _selectedGenre == genre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _filterByGenre(genre);
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.purple.withOpacity(0.7),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            // ================================
            // 🔍 KẾT QUẢ TÌM KIẾM
            // ================================
            if (_filteredSongs.isNotEmpty) ...[
              Text(
                "Tìm thấy ${_filteredSongs.length} bài hát",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: _filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _filteredSongs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              songList: _filteredSongs.map((s) => {
                                "title": s["title"] as String,
                                "file": s["file"] as String,
                              }).toList(),
                              currentIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.music_note, size: 32, color: Colors.purple[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song["title"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Thể loại: ${song["genre"]!}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      Icon(
                                        Icons.play_circle_filled,
                                        color: Colors.purple[700],
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // Không tìm thấy kết quả
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Không tìm thấy bài hát",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Hãy thử thay đổi từ khóa hoặc thể loại",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
