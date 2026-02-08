class TokenResponse {
  final String token;
  final String correo;
  final String nombre;

  TokenResponse({required this.token, required this.correo, required this.nombre});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
      correo: json['correo'],
      nombre: json['nombre'],
    );
  }
}