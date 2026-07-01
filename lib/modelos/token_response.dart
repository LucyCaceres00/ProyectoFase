class TokenResponse {
  final String token;
  final String correo;
  final String nombre;
  final int? usuarioId;

  TokenResponse({
    required this.token, 
    required this.correo, 
    required this.nombre,
    this.usuarioId  
    });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
      correo: json['correo'],
      nombre: json['nombre'],
      usuarioId: json['usuarioId'] != null ? json['usuarioId'] as int : null,
    );
  }
}