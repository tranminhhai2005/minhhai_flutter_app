import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minhhai/auth_service.dart';
import 'package:minhhai/recently_played_helper.dart';
import 'package:minhhai/sleep_timer_helper.dart';
import 'package:minhhai/screens/equalizer_screen.dart';

class PlayerScreen extends StatefulWidget {
  final List<Map<String, String>> songList;
  final int currentIndex;

  const PlayerScreen({
    super.key,
    required this.songList,
    required this.currentIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLiked = false;
  late int _currentIndex;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  
  bool _sleepTimerActive = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _loadSong(widget.songList[_currentIndex]);
    _listenToPlayer();
    _loadLiked();
    _loadComments();
  }

  Map<String, String> get _currentSong => widget.songList[_currentIndex];

  void _listenToPlayer() {
    _positionSub = _player.positionStream.listen((p) {
      setState(() => _position = p);
    });
    _durationSub = _player.durationStream.listen((d) {
      setState(() => _duration = d ?? Duration.zero);
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _loadLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "liked_${username}_${_currentSong["title"]}";
    setState(() {
      _isLiked = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "liked_${username}_${_currentSong["title"]}";
    
    setState(() {
      _isLiked = !_isLiked;
    });

    // Cập nhật trạng thái yêu thích
    prefs.setBool(key, _isLiked);
    
    // Cập nhật danh sách yêu thích của tài khoản
    List<String> favList = prefs.getStringList("favorites_$username") ?? [];
    if (_isLiked) {
      if (!favList.contains(_currentSong["title"])) {
        favList.add(_currentSong["title"]!);
      }
    } else {
      favList.remove(_currentSong["title"]);
    }
    prefs.setStringList("favorites_$username", favList);
  }

  Future<void> _loadSong(Map<String, String> song) async {
    try {
      await _player.setAsset("assets/music/${song['file']}");
      await _player.play();
      setState(() {
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _addToHistory(song['title']!);
      
      // Thêm vào danh sách phát gần đây
      if (AuthService.currentUser != null) {
        await RecentlyPlayedHelper.addToRecentlyPlayed(
          AuthService.currentUser!,
          song['title']!,
          song['file']!,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Lỗi phát nhạc: $e")));
    }
  }

  Future<void> _addToHistory(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "history_$username";
    
    List<String> history = prefs.getStringList(key) ?? [];
    history.remove(title);
    history.insert(0, title);
    if (history.length > 10) history = history.sublist(0, 10);
    prefs.setStringList(key, history);
  }

  void _nextSong() {
    final next = (_currentIndex + 1) % widget.songList.length;
    _loadSong(widget.songList[next]);
    setState(() {
      _currentIndex = next;
      _loadLiked();
      _loadComments();
    });
  }

  void _prevSong() {
    final prev =
        (_currentIndex - 1 + widget.songList.length) % widget.songList.length;
    _loadSong(widget.songList[prev]);
    setState(() {
      _currentIndex = prev;
      _loadLiked();
      _loadComments();
    });
  }

  void _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "comments_${username}_${_currentSong["title"]}";
    final saved = prefs.getStringList(key) ?? [];
    setState(() => _comments = saved);
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "comments_${username}_${_currentSong["title"]}";
    setState(() {
      _comments.add(text.trim());
    });
    prefs.setStringList(key, _comments);
    _commentController.clear();
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }


  void _showPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: _getPlaylists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            List<String> playlists = snapshot.data ?? [];
            final newPlaylistCtrl = TextEditingController();

            return AlertDialog(
              title: const Text("Thêm vào danh sách phát"),
              content: playlists.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Chưa có danh sách phát nào. Tạo mới:"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: newPlaylistCtrl,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên danh sách phát",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(playlists[index]),
                                onTap: () {
                                  _addToPlaylist(playlists[index]);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        const Text("Hoặc tạo mới:"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: newPlaylistCtrl,
                          decoration: const InputDecoration(
                            hintText: "Nhập tên danh sách phát",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newPlaylistCtrl.text.trim().isNotEmpty) {
                      _createPlaylist(newPlaylistCtrl.text.trim());
                      _addToPlaylist(newPlaylistCtrl.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Tạo & Thêm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> _getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    return prefs.getStringList("playlists_$username") ?? [];
  }

  Future<void> _createPlaylist(String playlistName) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final playlists = prefs.getStringList("playlists_$username") ?? [];
    if (!playlists.contains(playlistName)) {
      playlists.add(playlistName);
      await prefs.setStringList("playlists_$username", playlists);
    }
  }

  Future<void> _addToPlaylist(String playlistName) async {
    final prefs = await SharedPreferences.getInstance();
    final username = AuthService.currentUser ?? "guest";
    final key = "playlist_${username}_$playlistName";
    
    // Lấy danh sách bài hát trong playlist
    List<String> playlistSongs = prefs.getStringList(key) ?? [];
    
    // Thêm bài hát hiện tại
    final songTitle = _currentSong["title"]!;
    if (!playlistSongs.contains(songTitle)) {
      playlistSongs.add(songTitle);
      await prefs.setStringList(key, playlistSongs);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Đã thêm '$songTitle' vào '$playlistName'"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ℹ️ '$songTitle' đã có trong '$playlistName'"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ================================
  // 🛌 Sleep Timer
  // ================================
  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⏱ Hẹn giờ tắt nhạc"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            "10 phút",
            "20 phút",
            "30 phút",
            "45 phút",
            "60 phút"
          ]
              .map((time) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final minutes = int.parse(time.split(" ")[0]);
                        SleepTimerHelper.startSleepTimer(minutes, () {
                          _player.stop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("⏱ Hẹn giờ hết, dừng phát nhạc")),
                            );
                          }
                        });
                        setState(() => _sleepTimerActive = true);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("✅ Đặt hẹn giờ $time")),
                        );
                      },
                      child: Text(time),
                    ),
                  ))
              .toList(),
        ),
        actions: [
          if (SleepTimerHelper.isTimerActive())
            TextButton(
              onPressed: () {
                SleepTimerHelper.cancelSleepTimer();
                setState(() => _sleepTimerActive = false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Đã hủy hẹn giờ")),
                );
              },
              child: const Text("Hủy hẹn giờ"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  // ================================
  // 🎛 Equalizer
  // ================================
  void _openEqualizer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EqualizerScreen()),
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    _commentController.dispose();
    SleepTimerHelper.cancelSleepTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = _currentSong;

    return Scaffold(
      appBar: AppBar(
        title: Text("🎧 ${song["title"]}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
            ),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/background.jpg",
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Tên bài hát
            Text(
              song["title"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Thanh tiến trình
            ProgressBar(
              progress: _position,
              total: _duration,
              onSeek: (value) => _player.seek(value),
              baseBarColor: Colors.grey[300]!,
              progressBarColor: Colors.deepPurple,
              thumbColor: Colors.deepPurpleAccent,
              timeLabelTextStyle: const TextStyle(fontSize: 14),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position),
                    style: const TextStyle(color: Colors.grey)),
                Text(_formatTime(_duration),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),

            // Nút điều khiển
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    iconSize: 45,
                    color: Colors.deepPurple,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _prevSong),
                IconButton(
                  iconSize: 70,
                  color: Colors.deepPurple,
                  icon: Icon(
                      _isPlaying ? Icons.pause_circle : Icons.play_circle_fill),
                  onPressed: _playPause,
                ),
                IconButton(
                    iconSize: 45,
                    color: Colors.deepPurple,
                    icon: const Icon(Icons.skip_next),
                    onPressed: _nextSong),
              ],
            ),
            const SizedBox(height: 25),

            // 🎶 Thêm vào danh sách phát
            ElevatedButton.icon(
              onPressed: _showPlaylistDialog,
              icon: const Icon(Icons.playlist_add),
              label: const Text("Thêm vào danh sách phát"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 15),

            // 🎛 Equalizer & ⏱ Sleep Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _openEqualizer,
                  icon: const Icon(Icons.equalizer),
                  label: const Text("🎛 EQ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showSleepTimerDialog,
                  icon: const Icon(Icons.timer),
                  label: const Text("⏱ Timer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text("🎵 ${song['file']}",
                style: const TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),

            // 💬 Bình luận
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("💬 Bình luận",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            for (var comment in _comments)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person,
                        color: Color.fromARGB(255, 162, 200, 66)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(comment)),
                  ],
                ),
              ),

            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Nhập bình luận...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addComment(_commentController.text),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 128, 192, 59)),
                  child: const Text("Gửi"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
