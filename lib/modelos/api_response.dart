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
        json['EstatusCode'] ?? json['StatusCode'] ?? json['statusCode'] ?? 0;
    final message = json['Message'] ?? json['message'] ?? '';
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
