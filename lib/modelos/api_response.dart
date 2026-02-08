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
    // Manejar diferentes formatos de respuesta
    // Formato 1: {statusCode, message, data, success}
    // Formato 2: {EstatusCode, Message, Data, Succeeded} (tu API)

    final statusCode = json['statusCode'] ??
                      json['EstatusCode'] ??
                      json['estatusCode'] ??
                      0;

    final message = json['message'] ??
                   json['Message'] ??
                   json['mensaje'] ??
                   json['Mensaje'] ??
                   '';

    final dataField = json['data'] ??
                     json['Data'] ??
                     json['datos'] ??
                     json['Datos'];

    final success = json['success'] ??
                   json['Success'] ??
                   json['Succeeded'] ??
                   (statusCode >= 200 && statusCode < 300);

    return ApiResponse<T>(
      statusCode: statusCode,
      message: message,
      data: dataField != null && fromJsonData != null
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
