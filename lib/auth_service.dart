import 'database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static String? currentUser;

  /// �ang nh?p ngu?i d�ng
  static Future<bool> login(String username, String password) async {
    try {
      final db = await DatabaseHelper.database;
      final hashedPassword = _hashPassword(password);

      final result = await db.query(
        DatabaseHelper.tableUser,
        where: '${DatabaseHelper.columnUsername} = ? AND ${DatabaseHelper.columnPassword} = ?',
        whereArgs: [username, hashedPassword],
      );

      if (result.isNotEmpty) {
        currentUser = username;
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  /// �ang k� ngu?i d�ng
  static Future<bool> register(String username, String password, String email, String phone) async {
    try {
      final db = await DatabaseHelper.database;

      // Ki?m tra xem t�i kho?n d� t?n t?i chua
      final existing = await db.query(
        DatabaseHelper.tableUser,
        where: '${DatabaseHelper.columnUsername} = ?',
        whereArgs: [username],
      );

      if (existing.isNotEmpty) {
        return false; // T�i kho?n d� t?n t?i
      }

      final hashedPassword = _hashPassword(password);

      await db.insert(
        DatabaseHelper.tableUser,
        {
          DatabaseHelper.columnUsername: username,
          DatabaseHelper.columnPassword: hashedPassword,
          DatabaseHelper.columnEmail: email,
          DatabaseHelper.columnPhone: phone,
          DatabaseHelper.columnCreatedAt: DateTime.now().toIso8601String(),
        },
      );

      currentUser = username;
      return true;
    } catch (e) {
      print('❌ Register error: $e');
      return false;
    }
  }

  /// L?y t?t c? ngu?i d�ng
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await DatabaseHelper.database;
      return await db.query(DatabaseHelper.tableUser);
    } catch (e) {
      print('❌ Get all users error: $e');
      return [];
    }
  }

  /// C?p nh?t th�ng tin ngu?i d�ng
  static Future<bool> updateUser(String username, Map<String, dynamic> data) async {
    try {
      final db = await DatabaseHelper.database;

      await db.update(
        DatabaseHelper.tableUser,
        data,
        where: '${DatabaseHelper.columnUsername} = ?',
        whereArgs: [username],
      );

      return true;
    } catch (e) {
      print('Update user error: ');
      return false;
    }
  }

  /// �ang xu?t
  static void logout() {
    currentUser = null;
  }

  /// M� h�a m?t kh?u
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
