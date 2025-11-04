import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/article.dart';

class ArticleService {
  late final Dio _dio;

  ArticleService() {
    final baseUrl = kIsWeb
        ? "http://localhost:8080/api" // 웹 전용 백엔드 URL
        : Platform.isAndroid
        ? 'http://10.0.2.2:8080/api' // Android 에뮬레이터에서 실행할 때
        : 'http://localhost:8080/api'; // iOS 시뮬레이터에서 실행할 때

    _dio = Dio(
      BaseOptions(
        // baseUrl: "http://localhost:8080/api", // 웹 전용 백엔드 URL
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // 전체 게시글 불러오기
  Future<List<Article>> getArticles({int page = 1}) async {
    try {
      final response = await _dio.get(
        "/articles",
        queryParameters: {"page": page},
      );
      final List<dynamic> data =
          response.data['items']; // fastAPI pagination 구조 기준
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 사이트별 게시글 불러오기
  Future<List<Article>> getArticlesBySite(String site, {int page = 1}) async {
    try {
      final response = await _dio.get(
        "/articles/sitename/$site",
        queryParameters: {"page": page},
      );
      final List<dynamic> data =
          response.data['items']; // fastAPI pagination 구조 기준
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
