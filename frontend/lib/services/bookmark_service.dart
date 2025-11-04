import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/article.dart';

class BookmarkService {
  late final Dio _dio;

  BookmarkService() {
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

  /// 즐겨찾기된 게시물 전체 가져오기
  Future<List<Article>> getBookmarkedArticles() async {
    try {
      final response = await _dio.get("/bookmarks");
      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 특정 게시물 즐겨찾기 추가
  Future<bool> addBookmark(String articleID, String siteName) async {
    try {
      await _dio.post(
        // "/bookmarks/$siteName/$articleID", // http://localhost:8080/api/bookmarks/dcinside/dcinside_374999
        //호출 방식: ?article_id=dcinside_374993&site_name=dcinside
        "/bookmarks",
        queryParameters: {"article_id": articleID, "site_name": siteName},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 특정 게시물 즐겨찾기 삭제
  Future<bool> removeBookmark(String articleID, String siteName) async {
    try {
      await _dio.delete(
        // "/bookmarks/$siteName/$articleID",
        "/bookmarks",
        queryParameters: {"article_id": articleID, "site_name": siteName},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
