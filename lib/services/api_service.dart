import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/meeting_response.dart';
import '../utils/app_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          AppConstants.headerApiKey: AppConstants.apiKey,
          AppConstants.headerContentType: AppConstants.contentTypeJson,
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Future<MeetingResponse> createMeeting({required String userType}) async {
    try {
      final response = await _dio.post(
        AppConstants.meetingsEndpoint,
        queryParameters: {'type': userType},
      );

      return MeetingResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error creating meeting: $e');
    }
  }

  Future<MeetingResponse> joinMeeting({
    required String userType,
    required String meetingId,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.meetingsEndpoint,
        queryParameters: {
          'type': userType,
          'meeting_id': meetingId,
        },
      );

      return MeetingResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Error joining meeting: $e');
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Request failed';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void dispose() {
    _dio.close();
  }
}
