import 'package:flutter/material.dart';
import 'package:frontend/services/bookmark_service.dart';
import '../models/article.dart';
import '../widgets/article_items.dart';

class LikeFeedPage extends StatefulWidget {
  const LikeFeedPage({super.key});

  @override
  State<LikeFeedPage> createState() => _LikeFeedPageState();
}

class _LikeFeedPageState extends State<LikeFeedPage> {
  final BookmarkService _bookmarkService = BookmarkService();
  final ScrollController _scrollController = ScrollController();

  List<Article> _articles = [];
  bool _isLoading = true;
  // int _currentPage = 1;
  // bool _hasMore = true;
  // bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedArticles();

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels >=
    //           _scrollController.position.maxScrollExtent - 200 &&
    //       !_isLoading &&
    //       _hasMore &&
    //       !_isLoadingMore) {
    //     _loadMoreBookmarkedArticles();
    //   }
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkedArticles({int page = 1}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        // _currentPage = 1;
        // _hasMore = true;
        _articles.clear();
      });

      final fetchedArticles = await _bookmarkService.getBookmarkedArticles();
      setState(() {
        _articles = fetchedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Future<void> _loadMoreBookmarkedArticles() async {
  //   if (!_hasMore) return;

  //   setState(() => _isLoadingMore = true);

  //   try {
  //     final fetchedArticles = await _bookmarkService.getBookmarkedArticles();
  //     setState(() {
  //       if (fetchedArticles.isEmpty) {
  //         _hasMore = false;
  //       } else {
  //         _currentPage++;
  //         _articles.addAll(fetchedArticles);
  //       }
  //       _isLoadingMore = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoadingMore = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("즐겨찾기"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBookmarkedArticles(),
          ),
        ],
      ),
      body: Column(
        children: [
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
              onPressed: _loadBookmarkedArticles,
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
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('즐겨찾기한 게시물이 없습니다'),
          ],
        ),
      );
    }

    return ListView.builder(
      // controller: _scrollController,
      // itemCount: _articles.length + (_isLoadingMore ? 1 : 0),
      padding: const EdgeInsets.only(top: 8),
      itemCount: _articles.length,
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
