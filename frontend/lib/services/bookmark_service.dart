import 'package:dio/dio.dart';
import '../models/article.dart';

class BookmarkService {
  final Dio _dio;

  BookmarkService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:8080/api",
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

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
