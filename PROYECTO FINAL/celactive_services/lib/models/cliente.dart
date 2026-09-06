class Cliente {
  final int idCliente;
  final String nombre;
  final String correo;
  final String telefono;
  final String? token; // ✅ campo opcional para el token

  Cliente({
    required this.idCliente,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.token,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      nombre: json['user'],
      correo: json['correo'],
      telefono: json['telefono'] ?? '',
      token: json['token'], // ✅ si el backend lo envía
    );
  }
}


