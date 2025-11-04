import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/article.dart';

class SearchService {
  late final Dio _dio;

  SearchService() {
    String baseUrl;

    if (kIsWeb) {
      baseUrl = "http://localhost:8080/api"; // 웹 전용 백엔드 URL
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:8080/api'; // Android 에뮬레이터용
    } else {
      baseUrl = 'http://localhost:8080/api'; // iOS 시뮬레이터용
    }

    _dio = Dio(
      BaseOptions(
        // baseUrl: "http://localhost:8080/api", // 웹 전용 백엔드 URL
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // 검색된 결과 게시물 불러오기
  Future<List<Article>> searchArticles(String keyword) async {
    try {
      final response = await _dio.get(
        "/search",
        queryParameters: {"keyword": keyword},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      rethrow;

      /// ???이거 뭐지
    }
  }
}
