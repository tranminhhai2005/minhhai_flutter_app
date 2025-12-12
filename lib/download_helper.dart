import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DownloadHelper {
  static const String _downloadedKey = 'downloaded_songs';

  /// Thêm bài hát vào danh sách đã tải
  static Future<void> addToDownloaded(String username, String title, String file, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_downloadedKey}_$username';

    List<String> downloadedList = prefs.getStringList(key) ?? [];

    final song = jsonEncode({
      'title': title,
      'file': file,
      'filePath': filePath,
      'downloadedAt': DateTime.now().toIso8601String(),
    });

    // Xóa nếu đã tồn tại
    downloadedList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['title'] == title;
    });

    downloadedList.insert(0, song);
    await prefs.setStringList(key, downloadedList);
  }

  /// Lấy danh sách bài tải xuống
  static Future<List<Map<String, dynamic>>> getDownloadedSongs(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_downloadedKey}_$username';

    final List<String> downloadedList = prefs.getStringList(key) ?? [];
    return downloadedList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Kiểm tra xem bài hát đã được tải chưa
  static Future<bool> isDownloaded(String username, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_downloadedKey}_$username';

    final List<String> downloadedList = prefs.getStringList(key) ?? [];
    return downloadedList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['title'] == title;
    });
  }

  /// Xóa bài hát đã tải
  static Future<void> removeDownloaded(String username, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_downloadedKey}_$username';

    List<String> downloadedList = prefs.getStringList(key) ?? [];
    downloadedList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['title'] == title;
    });

    await prefs.setStringList(key, downloadedList);
  }

  /// Lấy file path của bài tải xuống
  static Future<String?> getDownloadedFilePath(String username, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_downloadedKey}_$username';

    final List<String> downloadedList = prefs.getStringList(key) ?? [];
    for (var item in downloadedList) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      if (decoded['title'] == title) {
        return decoded['filePath'] as String?;
      }
    }
    return null;
  }
}
