import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeHelper {
  /// Tạo dữ liệu QR từ thông tin user (JSON format)
  static String generateQRData(Map<String, dynamic> userData) {
    final qrData = {
      'username': userData['username'],
      'email': userData['email'],
      'phone': userData['phone'],
      'created_at': userData['created_at'],
      'type': 'profile', // Để nhận biết đây là QR profile
    };
    return jsonEncode(qrData);
  }

  /// Parse QR data để lấy thông tin user
  static Map<String, dynamic>? parseQRData(String qrData) {
    try {
      final decoded = jsonDecode(qrData) as Map<String, dynamic>;
      if (decoded['type'] == 'profile') {
        return decoded;
      }
      return null;
    } catch (e) {
      print('Error parsing QR data: $e');
      return null;
    }
  }

  /// Lưu lịch sử QR đã chia sẻ
  static Future<void> saveQRShare(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'qr_shares_$username';
    
    final shares = prefs.getStringList(key) ?? [];
    shares.insert(0, DateTime.now().toIso8601String());
    
    // Chỉ giữ 50 lần chia sẻ gần nhất
    if (shares.length > 50) {
      shares.removeRange(50, shares.length);
    }
    
    await prefs.setStringList(key, shares);
  }

  /// Lấy lịch sử chia sẻ QR
  static Future<List<DateTime>> getQRShareHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'qr_shares_$username';
    
    final shares = prefs.getStringList(key) ?? [];
    return shares.map((s) => DateTime.parse(s)).toList();
  }

  /// Xóa lịch sử chia sẻ
  static Future<void> clearQRShareHistory(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'qr_shares_$username';
    await prefs.remove(key);
  }
}
