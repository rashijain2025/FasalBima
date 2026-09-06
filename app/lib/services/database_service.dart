import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'farmer_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        profile_image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create crops table
    await db.execute('''
      CREATE TABLE crops (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        planting_date TEXT NOT NULL,
        expected_harvest_date TEXT,
        area TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        image_url TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create claims table
    await db.execute('''
      CREATE TABLE claims (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        crop_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        damage_type TEXT NOT NULL,
        severity TEXT NOT NULL,
        location TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        image_url TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (crop_id) REFERENCES crops (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_crops_user_id ON crops(user_id)');
    await db.execute('CREATE INDEX idx_claims_user_id ON claims(user_id)');
    await db.execute('CREATE INDEX idx_claims_crop_id ON claims(crop_id)');
  }

  // User operations
  Future<String> createUser({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String passwordHash,
    String? profileImageUrl,
  }) async {
    final db = await database;
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'password_hash': passwordHash,
      'profile_image_url': profileImageUrl,
      'created_at': now,
      'updated_at': now,
    });

    return userId;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<bool> verifyPassword(String email, String passwordHash) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['password_hash'] == passwordHash;
    }
    return false;
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
