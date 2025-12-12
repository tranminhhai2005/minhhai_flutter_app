import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecentlyPlayedHelper {
  static const String _key = 'recently_played';
  static const int _maxItems = 10;

  /// Thêm bài hát vào danh sách phát gần đây
  static Future<void> addToRecentlyPlayed(String username, String title, String file) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_key}_$username';

    // Lấy danh sách hiện tại
    List<String> recentList = prefs.getStringList(key) ?? [];

    // Tạo đối tượng bài hát
    final song = jsonEncode({
      'title': title,
      'file': file,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Xóa nếu đã tồn tại để đưa lên đầu
    recentList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['title'] == title;
    });

    // Thêm vào đầu
    recentList.insert(0, song);

    // Giới hạn chỉ giữ 10 bài gần nhất
    if (recentList.length > _maxItems) {
      recentList = recentList.sublist(0, _maxItems);
    }

    await prefs.setStringList(key, recentList);
  }

  /// Lấy danh sách phát gần đây
  static Future<List<Map<String, dynamic>>> getRecentlyPlayed(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_key}_$username';

    final List<String> recentList = prefs.getStringList(key) ?? [];
    return recentList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Xóa danh sách phát gần đây
  static Future<void> clearRecentlyPlayed(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_key}_$username';
    await prefs.remove(key);
  }
}
