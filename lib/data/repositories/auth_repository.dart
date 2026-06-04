import '../models/user.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String username, String password);
  Future<AppUser?> getUserById(String id);
  Future<void> saveSession(String userId);
  Future<String?> getStoredUserId();
  Future<void> clearSession();
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _users = {
      'arduino.esposito': _UserRecord(
        user: const AppUser(
          id: 'u1',
          username: 'arduino.esposito',
          displayName: 'Arduino Esposito',
          role: UserRole.operatore,
          initials: 'AE',
        ),
        password: 'demo123',
      ),
      'admin.siem': _UserRecord(
        user: const AppUser(
          id: 'u2',
          username: 'admin.siem',
          displayName: 'Admin SIEM',
          role: UserRole.amministratore,
          initials: 'AS',
        ),
        password: 'admin123',
      ),
    };
  }

  late final Map<String, _UserRecord> _users;
  String? _sessionUserId;

  @override
  Future<AppUser?> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final key = username.trim().toLowerCase();
    final record = _users[key];
    if (record == null || record.password != password) return null;
    _sessionUserId = record.user.id;
    return record.user;
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (final record in _users.values) {
      if (record.user.id == id) return record.user;
    }
    return null;
  }

  @override
  Future<void> saveSession(String userId) async {
    _sessionUserId = userId;
  }

  @override
  Future<String?> getStoredUserId() async => _sessionUserId;

  @override
  Future<void> clearSession() async {
    _sessionUserId = null;
  }
}

class _UserRecord {
  const _UserRecord({required this.user, required this.password});

  final AppUser user;
  final String password;
}
