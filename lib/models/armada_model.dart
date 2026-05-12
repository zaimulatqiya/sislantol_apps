class ArmadaModel {
  final String id;
  final String namaArmada;
  final String platNomor;
  final String status; // 'tersedia' | 'bertugas'

  ArmadaModel({
    required this.id,
    required this.namaArmada,
    required this.platNomor,
    required this.status,
  });

  factory ArmadaModel.fromJson(Map<String, dynamic> json) {
    return ArmadaModel(
      id: json['id'],
      namaArmada: json['namaArmada'],
      platNomor: json['platNomor'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaArmada': namaArmada,
      'platNomor': platNomor,
      'status': status,
    };
  }
}
