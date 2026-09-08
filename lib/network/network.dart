import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class HttpClientConnection {
  final bool isLoggingEnabled = true;

  static const Duration connectTimeout = Duration(seconds: 100);
  static const Duration receiveTimeout = Duration(seconds: 100);

  late final Dio _dio;

  HttpClientConnection({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _getToken();
          if (token.isNotEmpty) {
            options.headers["Authorization"] = "Token $token";
          }
          return handler.next(options);
        },
      ),
    );

    if (isLoggingEnabled) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  String _getToken() {
    return '';
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("No internet connection");
    }
  }

  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return Exception("Connection timeout");
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception("No internet connection");
    }

    if ((error.response?.statusCode ?? 0) >= 500) {
      return Exception("Server error. Please try again later");
    }

    if (error.response?.statusCode == 401) {
      return Exception("Session expired");
    }

    return Exception(
      error.response?.data?['message'] ??
          error.response?.statusMessage ??
          "Something went wrong",
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    required T Function(dynamic data) fromJson,
  }) async {
    await _checkConnectivity();

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers, responseType: responseType),
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) fromJson,
  }) async {
    await _checkConnectivity();

    try {
      final response = await _dio.post(
        path,
        data: body,
        options: Options(headers: headers),
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) fromJson,
  }) async {
    await _checkConnectivity();

    try {
      final response = await _dio.patch(
        path,
        data: body,
        options: Options(headers: headers),
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required T Function(dynamic data) fromJson,
  }) async {
    await _checkConnectivity();

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return (response.data as List).map((e) => fromJson(e)).toList();
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  Future<T> uploadMedia<T>(
    String path,
    File file, {
    Map<String, dynamic>? headers,
    required T Function(dynamic data) fromJson,
  }) async {
    await _checkConnectivity();

    final fileName = file.path.split('/').last;
    final mimeType = lookupMimeType(file.path) ?? '';
    final type = mimeType.split('/');

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: type.length == 2 ? MediaType(type[0], type[1]) : null,
      ),
    });

    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers),
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  ResponseType getResponseTypeForCSV() => ResponseType.plain;

  ResponseType getResponseTypeForPDF() => ResponseType.bytes;
}
