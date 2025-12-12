import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minhhai/screens/player_screen.dart';
import 'package:minhhai/auth_service.dart';

// Danh sách tất cả bài hát
const List<Map<String, String>> allSongs = [
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
  {"title": "Gánh mẹ", "file": "song1.m4a"},
  {"title": "Thành Phố Buồn", "file": "song2.m4a"},
  {"title": "Thái Hoàng", "file": "song3.mp3"},
];

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<String> _playlistSongs = [];
  List<Map<String, String>> _songList = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "playlist_${username}_${widget.playlistName}";

    final songs = prefs.getStringList(key) ?? [];
    
    // Chuyển đổi tên bài hát thành map đầy đủ
    final songMapList = <Map<String, String>>[];
    for (var title in songs) {
      final songMap = allSongs.firstWhere(
        (song) => song["title"] == title,
        orElse: () => {"title": title, "file": "$title.mp3"},
      );
      songMapList.add(songMap);
    }

    setState(() {
      _playlistSongs = songs;
      _songList = songMapList;
    });
  }

  Future<void> _removeSongFromPlaylist(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "playlist_${username}_${widget.playlistName}";

    _playlistSongs.removeAt(index);
    await prefs.setStringList(key, _playlistSongs);
    
    setState(() {
      _songList.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🗑️ Đã xóa khỏi playlist"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 70, 177),
        title: Row(
          children: [
            const Icon(Icons.queue_music, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.playlistName,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _songList.isEmpty
          ? const Center(
              child: Text("📭 Playlist trống. Thêm bài hát từ trình phát!"),
            )
          : ListView.builder(
              itemCount: _songList.length,
              itemBuilder: (context, index) {
                final song = _songList[index];
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.purple),
                  title: Text(song["title"]!),
                  subtitle: Text(song["file"]!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSongFromPlaylist(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          songList: _songList,
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
