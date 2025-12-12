import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minhhai/screens/player_screen.dart';
import 'package:minhhai/screens/playlist_detail_screen.dart';
import 'package:minhhai/auth_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<String> _favoriteSongs = [];
  List<String> _historySongs = [];
  List<String> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    
    setState(() {
      _favoriteSongs = prefs.getStringList("favorites_$username") ?? [];
      _historySongs = prefs.getStringList("history_$username") ?? [];
      _playlists = prefs.getStringList("playlists_$username") ?? [];
    });
  }

  Future<void> _deletePlaylist(String playlistName) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    
    _playlists.remove(playlistName);
    await prefs.setStringList("playlists_$username", _playlists);
    
    // Xóa dữ liệu playlist
    await prefs.remove("playlist_${username}_$playlistName");
    
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ Đã xóa playlist '$playlistName'")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 70, 177),

        // 🔵 sửa tiêu đề + icon thành màu xanh dương
        title: const Row(
          children: [
            Icon(Icons.library_music, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Thư viện",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ❤️ YÊU THÍCH
              const Text(
                "❤️ Thư viện yêu thích",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _favoriteSongs.isEmpty
                  ? const Text("Chưa có bài hát yêu thích nào...")
                  : Column(
                      children: _favoriteSongs.map((title) {
                        return ListTile(
                          leading:
                              const Icon(Icons.favorite, color: Colors.red),
                          title: Text(title),
                          subtitle: const Text("Đã thêm vào yêu thích"),
                          trailing: const Icon(Icons.play_arrow,
                              color: Colors.blue), // 🔵 icon play
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(
                                  songList: [
                                    {"title": title, "file": "$title.mp3"}
                                  ],
                                  currentIndex: 0,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

              const Divider(height: 30, thickness: 1),

              // 🕒 LỊCH SỬ NGHE
              const Text(
                "🕒 Lịch sử nghe nhạc",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _historySongs.isEmpty
                  ? const Text("Bạn chưa nghe bài hát nào gần đây.")
                  : Column(
                      children: _historySongs.map((title) {
                        return ListTile(
                          leading: const Icon(Icons.history,
                              color: Colors.blue), // 🔵 icon lịch sử
                          title: Text(title),
                          subtitle: const Text("Nghe gần đây"),
                        );
                      }).toList(),
                    ),

              const Divider(height: 30, thickness: 1),

              // 🎶 PLAYLISTS
              const Text(
                "🎶 Playlists",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _playlists.isEmpty
                  ? const Text("Chưa có danh sách phát nào...")
                  : Column(
                      children: _playlists.map((playlistName) {
                        return ListTile(
                          leading: const Icon(Icons.queue_music, color: Colors.blue),
                          title: Text(playlistName),
                          subtitle: const Text("Bấm để xem chi tiết"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePlaylist(playlistName),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaylistDetailScreen(
                                  playlistName: playlistName,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

              const Divider(height: 30, thickness: 1),

              // 👥 FOLLOWING
              const Text(
                "👥 Following",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading:
                    const Icon(Icons.person_add, color: Colors.blue), // 🔵 icon
                title: const Text("Nghệ sĩ bạn theo dõi"),
                subtitle: const Text("Tính năng đang phát triển..."),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("👥 Tính năng Following sắp ra mắt!")));
                },
              ),

              const Divider(height: 30, thickness: 1),

              // 💿 ALBUMS
              const Text(
                "💿 Albums",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.album, color: Colors.blue), // 🔵 icon
                title: const Text("Album của bạn"),
                subtitle: const Text("Tính năng đang phát triển..."),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("💿 Tính năng Albums sắp ra mắt!")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
