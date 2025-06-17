class ReglasIncumplidasTren {
  final String regla;
  final double sec;
  final String carro;
  final String descripcion;

  ReglasIncumplidasTren({
    required this.regla,
    required this.sec,
    required this.carro,
    required this.descripcion,
  });

  // Factory para crear una instancia de ReglaIncumplida a partir del JSON
  factory ReglasIncumplidasTren.fromJson(Map<String, dynamic> json) {
    return ReglasIncumplidasTren(
      regla: json['regla'] ?? 'N/A',
      sec: json['sec'] ?? 0,
      carro: json['carro'] ?? 'N/A',
      descripcion: json['descripcion'] ?? 'N/A',
    );
  }
}
