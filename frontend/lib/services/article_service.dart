import 'package:dio/dio.dart';
import '../models/article.dart';

class ArticleService {
  late final Dio _dio;

  ArticleService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:8080/api",
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
