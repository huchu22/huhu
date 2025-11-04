import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/article.dart';

class ReadstatusService {
  late final Dio _dio;

  ReadstatusService() {
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
  // 이미 읽은 게시물 목록 가져오기
  Future<List<Article>> getReadArticles() async {
    try {
      final response = await _dio.get("/readstatus");
      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 특정 게시물 읽음 상태 추가
  Future<bool> addReadArticle(String articleId, String siteName) async {
    try {
      await _dio.post(
        "/readstatus",
        queryParameters: {"article_id": articleId, "site_name": siteName},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
