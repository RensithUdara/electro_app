import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'electro_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_credentials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        remember_me INTEGER NOT NULL DEFAULT 0,
        last_login INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        phone_number TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        expires_at INTEGER
      )
    ''');
  }

  // Hash password for secure storage
  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}electro_app_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Save user credentials when remember me is checked
  Future<void> saveCredentials(
      String email, String password, bool rememberMe) async {
    final db = await database;
    final passwordHash = _hashPassword(password);
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'user_credentials',
      {
        'email': email,
        'password_hash': passwordHash,
        'remember_me': rememberMe ? 1 : 0,
        'last_login': now,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'user_credentials',
      where: 'remember_me = ?',
      whereArgs: [1],
      orderBy: 'last_login DESC',
      limit: 1,
    );

    if (results.isNotEmpty) {
      return {
        'email': results.first['email'] as String,
        'password_hash': results.first['password_hash'] as String,
      };
    }

    return null;
  }

  // Verify password
  bool verifyPassword(String password, String storedHash) {
    return _hashPassword(password) == storedHash;
  }

  // Save user session for persistent login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
    required String phoneNumber,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = now + (30 * 24 * 60 * 60 * 1000); // 30 days

    // Deactivate previous sessions for this user
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'email = ?',
      whereArgs: [email],
    );

    // Insert new session
    await db.insert(
      'user_sessions',
      {
        'user_id': userId,
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
        'is_active': 1,
        'created_at': now,
        'expires_at': expiresAt,
      },
    );
  }

  // Get active user session
  Future<Map<String, dynamic>?> getActiveSession() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, dynamic>> results = await db.query(
      'user_sessions',
      where: 'is_active = ? AND expires_at > ?',
      whereArgs: [1, now],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  // Clear user session (logout)
  Future<void> clearUserSession(String email) async {
    final db = await database;

    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Clear all sessions
  Future<void> clearAllSessions() async {
    final db = await database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
    );
  }

  // Remove saved credentials
  Future<void> removeCredentials(String email) async {
    final db = await database;
    await db.delete(
      'user_credentials',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Update remember me preference
  Future<void> updateRememberMe(String email, bool rememberMe) async {
    final db = await database;
    await db.update(
      'user_credentials',
      {'remember_me': rememberMe ? 1 : 0},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Check if credentials exist
  Future<bool> hasCredentials() async {
    final credentials = await getSavedCredentials();
    return credentials != null;
  }

  // Get last used email
  Future<String?> getLastUsedEmail() async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'user_credentials',
      columns: ['email'],
      orderBy: 'last_login DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first['email'] as String : null;
  }

  // Debug method to check stored data
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final credentials = await getSavedCredentials();
      final activeSession = await getActiveSession();
      final lastEmail = await getLastUsedEmail();
      final hasStoredCredentials = await hasCredentials();

      return {
        'has_credentials': hasStoredCredentials,
        'last_email': lastEmail,
        'saved_credentials': credentials != null
            ? {
                'email': credentials['email'],
                'has_password_hash':
                    credentials['password_hash']?.isNotEmpty ?? false,
              }
            : null,
        'active_session': activeSession != null
            ? {
                'user_id': activeSession['user_id'],
                'email': activeSession['email'],
                'name': activeSession['name'],
                'is_active': activeSession['is_active'],
                'expires_at': DateTime.fromMillisecondsSinceEpoch(
                    activeSession['expires_at']),
                'created_at': DateTime.fromMillisecondsSinceEpoch(
                    activeSession['created_at']),
              }
            : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
