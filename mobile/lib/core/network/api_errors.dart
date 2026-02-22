import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.original,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final DioException? original;

  static ApiException fromDio(DioException err) {
    final data = err.response?.data;
    final detail = data is Map ? data['detail'] : null;
    final code = detail is Map ? detail['code']?.toString() : null;
    final messageFromApi = detail is Map ? detail['message']?.toString() : null;

    if (messageFromApi != null && messageFromApi.isNotEmpty) {
      return ApiException(
        message: messageFromApi,
        code: code,
        statusCode: err.response?.statusCode,
        original: err,
      );
    }

    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map) {
        final msg = first['msg']?.toString();
        final loc = first['loc'];
        final field = (loc is List && loc.isNotEmpty)
            ? loc.last?.toString().replaceAll('_', ' ')
            : 'field';
        return ApiException(
          message: msg != null && msg.isNotEmpty
              ? '$field: $msg'
              : 'Invalid request data. Please check your input.',
          statusCode: err.response?.statusCode,
          original: err,
        );
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Server timeout. Please try again.',
          statusCode: err.response?.statusCode,
          original: err,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message:
              'Cannot reach server. Check API host or network and try again.',
          statusCode: err.response?.statusCode,
          original: err,
        );
      default:
        return ApiException(
          message: err.message ?? 'Request failed. Please try again.',
          statusCode: err.response?.statusCode,
          original: err,
        );
    }
  }

  DioException toDioException() {
    return DioException(
      requestOptions: original?.requestOptions ?? RequestOptions(path: ''),
      response: original?.response,
      type: original?.type ?? DioExceptionType.unknown,
      error: this,
      message: message,
    );
  }
}
