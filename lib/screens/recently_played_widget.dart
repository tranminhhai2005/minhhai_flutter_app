import 'package:flutter/material.dart';
import 'package:minhhai/recently_played_helper.dart';
import 'package:minhhai/auth_service.dart';
import 'package:minhhai/screens/player_screen.dart';

class RecentlyPlayedWidget extends StatefulWidget {
  const RecentlyPlayedWidget({super.key});

  @override
  State<RecentlyPlayedWidget> createState() => _RecentlyPlayedWidgetState();
}

class _RecentlyPlayedWidgetState extends State<RecentlyPlayedWidget> {
  List<Map<String, dynamic>> recentlyPlayed = [];

  @override
  void initState() {
    super.initState();
    _loadRecentlyPlayed();
  }

  Future<void> _loadRecentlyPlayed() async {
    if (AuthService.currentUser != null) {
      final recent = await RecentlyPlayedHelper.getRecentlyPlayed(AuthService.currentUser!);
      setState(() {
        recentlyPlayed = recent.take(10).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recentlyPlayed.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: Colors.deepPurple, size: 24),
              SizedBox(width: 8),
              Text(
                "🎧 Nghe gần đây",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentlyPlayed.length,
              itemBuilder: (context, index) {
                final song = recentlyPlayed[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          songList: recentlyPlayed
                              .map((s) => {
                                    "title": s["title"] as String,
                                    "file": s["file"] as String,
                                  })
                              .toList(),
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.music_note, size: 28, color: Colors.deepPurple),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            song["title"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
