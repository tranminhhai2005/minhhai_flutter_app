import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;

  // 🧱 Tên bảng và các cột
  static const String tableUser = "users";
  static const String columnId = "id";
  static const String columnUsername = "username";
  static const String columnPassword = "password";
  static const String columnEmail = "email";
  static const String columnPhone = "phone";
  static const String columnAvatar = "avatar_path";
  static const String columnCreatedAt = "created_at";

  // =====================================================
  // 🔹 Lấy database
  // =====================================================
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // =====================================================
  // 🔹 Khởi tạo database
  // =====================================================
  static Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, "music_app.db");
      print('📂 Database path: $path');

      return await openDatabase(
        path,
        version: 6,
        onCreate: (db, version) async {
          print('📝 Creating database tables...');
          await _createTable(db);
          print('✅ Database tables created');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print('🔄 Upgrading database from version $oldVersion to $newVersion');
          await db.execute("DROP TABLE IF EXISTS $tableUser");
          await _createTable(db);
        },
      );
    } catch (e) {
      print('❌ Database initialization error: $e');
      rethrow;
    }
  }

  // =====================================================
  // 🔹 Tạo bảng user
  // =====================================================
  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableUser (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT UNIQUE,
        $columnPassword TEXT,
        $columnEmail TEXT,
        $columnPhone TEXT,
        $columnAvatar TEXT,
        $columnCreatedAt TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    // 🧩 User mặc định admin
    final hashedAdminPass = sha256.convert(utf8.encode("123")).toString();

    await db.insert(tableUser, {
      columnUsername: "admin",
      columnPassword: hashedAdminPass,
      columnEmail: "admin@gmail.com",
      columnPhone: "0123456789",
      columnAvatar: "",
      columnCreatedAt: DateTime.now().toString(),
    });
  }

  // =====================================================
  // 🔹 Thêm user mới
  // =====================================================
  static Future<int> insertUser(
    String username,
    String password,
    String email,
    String phone,
    String avatarPath,
  ) async {
    final db = await database;

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    return await db.insert(
      tableUser,
      {
        columnUsername: username,
        columnPassword: hashedPassword,
        columnEmail: email,
        columnPhone: phone,
        columnAvatar: avatarPath,
        columnCreatedAt: DateTime.now().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  // =====================================================
  // 🔹 Lấy tất cả user
  // =====================================================
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(tableUser, orderBy: "$columnId DESC");
  }

  // =====================================================
  // 🔐 Kiểm tra đăng nhập
  // =====================================================
  static Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await database;

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final res = await db.query(
      tableUser,
      where: "$columnUsername = ? AND $columnPassword = ?",
      whereArgs: [username, hashedPassword],
    );

    if (res.isNotEmpty) return res.first;
    return null;
  }

  // =====================================================
  // 🔹 Lấy ngày tạo tài khoản
  // =====================================================
  static Future<String?> getCreatedAt(String username) async {
    final db = await database;

    final res = await db.query(
      tableUser,
      columns: [columnCreatedAt],
      where: "$columnUsername = ?",
      whereArgs: [username],
    );

    if (res.isNotEmpty) {
      return res.first[columnCreatedAt] as String?;
    }
    return null;
  }

  // =====================================================
  // 🔹 Lấy avatar
  // =====================================================
  static Future<String?> getAvatarPath(String username) async {
    final db = await database;

    final res = await db.query(
      tableUser,
      columns: [columnAvatar],
      where: "$columnUsername = ?",
      whereArgs: [username],
    );

    if (res.isNotEmpty) {
      return res.first[columnAvatar] as String?;
    }
    return null;
  }

  // =====================================================
  // 🔥 UPDATE USER — bản chuẩn null-safety
  // =====================================================
  static Future<void> updateUser({
    required String username,
    String? email,
    String? phone,
    String? avatarPath,
  }) async {
    final db = await database;

    await db.update(
      tableUser,
      {
        if (email != null) columnEmail: email,
        if (phone != null) columnPhone: phone,
        if (avatarPath != null) columnAvatar: avatarPath,
      },
      where: "$columnUsername = ?",
      whereArgs: [username],
    );
  }
}
