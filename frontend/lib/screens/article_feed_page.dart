import 'package:flutter/material.dart';
import '../services/article_service.dart';
import '../models/article.dart';
import '../widgets/article_items.dart';
import '../widgets/site_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleFeedPage extends StatefulWidget {
  const ArticleFeedPage({super.key});

  @override
  State<ArticleFeedPage> createState() => _ArticleFeedPageState();
}

class _ArticleFeedPageState extends State<ArticleFeedPage> {
  final ArticleService _articleService = ArticleService();
  final ScrollController _scrollController = ScrollController();

  List<Article> _articles = [];
  bool _isLoading = true; // 초기 로딩 상태
  int _currentPage = 1; // 현재 페이지
  bool _hasMore = true; // 더 불러올 게시물이 있는지 여부
  bool _isLoadingMore = false; // 다음 페이지 로딩 상태
  String? _errorMessage; // 오류 메시지
  String _selectedSite = 'all'; // 선택된 사이트 필터(첫 로딩 = 전체)

  @override
  void initState() {
    super.initState();
    _loadArticles();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _hasMore &&
          !_isLoadingMore &&
          !_isLoading) {
        _loadMoreArticles();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 다음 페이지 로딩
  Future<void> _loadMoreArticles() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;

    try {
      final fetchedArticles = _selectedSite == "all"
          ? await _articleService.getArticles(page: nextPage)
          : await _articleService.getArticlesBySite(
              _selectedSite,
              page: nextPage,
            );

      setState(() {
        if (fetchedArticles.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage = nextPage;
          _articles.addAll(fetchedArticles);
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _errorMessage = e.toString();
        _hasMore = false; // 에러 시 더 이상 시도 안 함
      });
    }
  }

  // ✅ 초기 로드 및 필터링 함수
  Future<void> _loadArticles({String site = 'all'}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMore = true;
      _articles.clear();
    });

    try {
      final fetchedArticles = site == "all"
          ? await _articleService.getArticles(page: 1)
          : await _articleService.getArticlesBySite(site, page: 1);

      setState(() {
        _articles = fetchedArticles;
        _isLoading = false;
        _hasMore = fetchedArticles.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _hasMore = false;
      });
    }
  }

  void _onSiteSelected(String site) {
    setState(() => _selectedSite = site);
    _loadArticles(site: site);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Community Hot Issue",
            style: GoogleFonts.amiko(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadArticles(), // site: _selectedSite
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 필터 버튼 추가
          SiteFilterButtons(
            selectedSite: _selectedSite,
            onSelected: _onSiteSelected,
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArticles,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('게시물이 없습니다'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _articles.length) {
          return ArticleItem(article: _articles[index]);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
