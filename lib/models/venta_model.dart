class Venta {
  final String vendedor;
  final String fecha;
  final String nombre;
  final String idM3;
  final String nDoc;
  final double valorNeto;
  final double valor;
  final String idHub;
  final String tmIdProceso;
  final String uuid;
  final String vendedor2;
  final String idTrx;
  final String idDiario;
  final String descripcion;
  final String nomCliente;

  Venta({
    required this.vendedor,
    required this.fecha,
    required this.nombre,
    required this.idM3,
    required this.nDoc,
    required this.valorNeto,
    required this.valor,
    required this.idHub,
    required this.tmIdProceso,
    required this.uuid,
    required this.vendedor2,
    required this.idTrx,
    required this.idDiario,
    required this.descripcion,
    required this.nomCliente,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      vendedor: json['Vendedor'] ?? '',
      fecha: json['Fecha'] ?? '',
      nombre: json['Nombre'] ?? '',
      idM3: json['IdM3'] ?? '',
      nDoc: json['NDoc'] ?? '',
      valorNeto: _parseDouble(json['ValorNeto']),
      valor: _parseDouble(json['Valor']),
      idHub: json['IDHub'] ?? '',
      tmIdProceso: json['TMIdProceso'] ?? '',
      uuid: json['UUID'] ?? '',
      vendedor2: json['Vendedor2'] ?? '',
      idTrx: json['IdTrx'] ?? '',
      idDiario: json['IdDiario'] ?? '',
      descripcion: json['Descripcion'] ?? '',
      nomCliente: json['NOM_Cliente'] ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
