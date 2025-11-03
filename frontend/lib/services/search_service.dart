import 'package:dio/dio.dart';
import '../models/article.dart';

class SearchService {
  final Dio _dio;

  SearchService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:8080/api",
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

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
