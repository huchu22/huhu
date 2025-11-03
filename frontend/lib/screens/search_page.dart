import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/article.dart';
import '../widgets/article_items.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchService _searchService = SearchService();
  final SearchController _searchController = SearchController();

  List<Article> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults.clear(); // ✅ 빈 검색어 시 결과 초기화
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await _searchService.searchArticles(keyword);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('게시물 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 400,
                child: SearchAnchor(
                  searchController: _searchController,
                  builder: (context, controller) {
                    return SearchBar(
                      controller: controller,
                      hintText: '검색어를 입력하세요...',
                      onSubmitted: (value) async {
                        final keyword = value.trim();
                        if (keyword.isEmpty) return;

                        await _performSearch(keyword);
                        // ✅ 검색 결과 보기 닫기 (중복 트리거 방지)
                        controller.openView();
                      },
                      leading: const Icon(Icons.search),
                      trailing: [
                        Tooltip(
                          message: '현재 입력값으로 검색',
                          child: IconButton(
                            onPressed: () async {
                              final keyword = _searchController.text.trim();
                              if (keyword.isEmpty) return;

                              await _performSearch(keyword);
                              _searchController.openView(); // ✅ 닫기 처리
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ),
                      ],
                    );
                  },
                  suggestionsBuilder: (context, controller) {
                    if (_isLoading) {
                      return [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ];
                    }

                    if (_errorMessage.isNotEmpty) {
                      return [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '오류 발생: $_errorMessage',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ];
                    }

                    if (_searchResults.isEmpty) {
                      return [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('검색 결과가 없습니다.'),
                        ),
                      ];
                    }

                    // ✅ 검색 결과 리스트
                    return _searchResults.map((article) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ArticleItem(article: article),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
