class UserModel {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String role; // 'pengguna' | 'petugas'

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      noHp: json['noHp'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'role': role,
    };
  }
}
