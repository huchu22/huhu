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

  Future<List<Article>> getArticles() async {
    try {
      final response = await _dio.get("/articles");
      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getArticlesBySite(String site) async {
    try {
      final response = await _dio.get("/articles/sitename/$site");
      final List<dynamic> data = response.data;
      return data.map((json) => Article.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
