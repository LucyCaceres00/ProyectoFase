class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T? data;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
    required this.success,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonData,
  }) {
    final statusCode =
        json['EstatusCode'] ??
        json['StatusCode'] ??
        json['statusCode'] ??
        json['status'] ?? // ASP.NET ValidationProblemDetails
        0;

    // Si el body no trae Message/message, puede ser un error automático de
    // ASP.NET Core (ValidationProblemDetails: { title, errors: {campo: [..]} })
    // en vez de nuestra clase Response<T> — por ejemplo cuando [ApiController]
    // rechaza el request por un campo no-nulo faltante antes de llegar al
    // controlador. Armamos un mensaje legible a partir de eso si aparece.
    String message = json['Message'] ?? json['message'] ?? '';
    if (message.isEmpty) {
      final titulo = json['title'] as String?;
      final errores = json['errors'];
      if (errores is Map && errores.isNotEmpty) {
        final detalle = errores.values
            .expand((v) => v is List ? v : [v])
            .map((e) => e.toString())
            .join(' ');
        message = detalle.isNotEmpty
            ? detalle
            : (titulo ?? 'Solicitud inválida');
      } else if (titulo != null && titulo.isNotEmpty) {
        message = titulo;
      }
    }

    final dataField = json['Data'] ?? json['data'];
    final success =
        json['Succeeded'] ??
        json['succeeded'] ??
        (statusCode >= 200 && statusCode < 300);

    return ApiResponse<T>(
      statusCode: statusCode,
      message: message,
      data: dataField != null && fromJsonData != null && (dataField is Map || dataField is List)
          ? fromJsonData(dataField)
          : dataField as T?,
      success: success,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse<T>(
      statusCode: statusCode,
      message: message,
      data: null,
      success: false,
    );
  }

  factory ApiResponse.success(T? data, {String message = 'Operación exitosa'}) {
    return ApiResponse<T>(
      statusCode: 200,
      message: message,
      data: data,
      success: true,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, message: $message, success: $success, data: $data)';
  }
}
