import '../../models/user_model.dart';

class MockAuthDataSource {
  final List<UserModel> _users = [
    UserModel(
      id: 'u1',
      nama: 'Budi Santoso',
      email: 'budi@gmail.com',
      noHp: '081234567890',
      role: 'pengguna',
    ),
    UserModel(
      id: 'p1',
      nama: 'Agus Petugas',
      email: 'agus@sislantol.com',
      noHp: '08111222333',
      role: 'petugas',
    ),
  ];

  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For mock, any password works if email is found
    if (password.isEmpty) {
      throw Exception('Password wajib diisi');
    }

    try {
      final user = _users.firstWhere((u) => u.email == email);
      return user;
    } catch (e) {
      throw Exception('Email tidak ditemukan');
    }
  }

  Future<UserModel> register(UserModel newUser) async {
    await Future.delayed(const Duration(seconds: 1));
    _users.add(newUser);
    return newUser;
  }
}
