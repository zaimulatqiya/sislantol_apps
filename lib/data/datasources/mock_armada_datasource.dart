import '../../models/armada_model.dart';

class MockArmadaDataSource {
  final List<ArmadaModel> _armadaList = [
    ArmadaModel(id: 'a1', namaArmada: 'Derek Besar 01', platNomor: 'L 1234 XY', status: 'tersedia'),
    ArmadaModel(id: 'a2', namaArmada: 'Patroli 05', platNomor: 'W 9999 ZZ', status: 'bertugas'),
  ];

  Future<List<ArmadaModel>> getAllArmada() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<ArmadaModel>.from(_armadaList);
  }
}
