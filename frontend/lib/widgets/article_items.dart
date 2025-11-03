import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/article_webview_page.dart';
import '../services/bookmark_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../services/readstatus_service.dart';

class ArticleItem extends StatefulWidget {
  final Article article;

  const ArticleItem({super.key, required this.article});

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  bool isBookmarked = false;
  bool isRead = false;
  final BookmarkService _bookmarkService = BookmarkService();
  final ReadstatusService _readService = ReadstatusService();

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _checkReadStatus();
  }

  void _checkReadStatus() async {
    final readArticles = await _readService.getReadArticles();
    if (mounted) {
      setState(() {
        isRead = readArticles.any(
          (a) =>
              a.articleID == widget.article.articleID &&
              a.siteName == widget.article.siteName,
        );
      });
    }
  }

  void _checkBookmarkStatus() async {
    final bookmarks = await _bookmarkService.getBookmarkedArticles();
    if (mounted) {
      setState(() {
        isBookmarked = bookmarks.any(
          (a) =>
              a.articleID == widget.article.articleID &&
              a.siteName == widget.article.siteName,
        );
      });
    }
  }

  void _toggleBookmark() async {
    if (isBookmarked) {
      await _bookmarkService.removeBookmark(
        widget.article.articleID,
        widget.article.siteName,
      );
    } else {
      await _bookmarkService.addBookmark(
        widget.article.articleID,
        widget.article.siteName,
      );
    }
    if (mounted) {
      setState(() => isBookmarked = !isBookmarked);
    }
  }

  void _openUrl(BuildContext context) async {
    if (kIsWeb) {
      final uri = Uri.parse(widget.article.siteUrl);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleWebviewPage(
            url: widget.article.siteUrl,
            title: widget.article.title,
          ),
        ),
      );
    }

    // 클릭 시 읽음 등록
    await _readService.addReadArticle(
      widget.article.articleID,
      widget.article.siteName,
    );
    if (mounted) {
      setState(() => isRead = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openUrl(context),
      child: Container(
        height: 136,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
        decoration: BoxDecoration(
          color: isRead ? Colors.grey.withValues(alpha: 0) : Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRead ? Colors.grey : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(widget.article.createDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _siteMapping(widget.article.siteName),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.star : Icons.star_border,
                color: isBookmarked
                    ? Colors.amber
                    : const Color.fromARGB(255, 158, 158, 158),
                size: 28,
              ),
              onPressed: _toggleBookmark,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _siteMapping(String code) {
    const siteMap = {
      "fmkorea": "에펨코리아",
      "dcinside": "디시인사이드",
      "naver": "네이버",
      "ruliweb": "루리웹",
      "theqoo": "더쿠",
    };
    return siteMap[code] ?? code;
  }
}
