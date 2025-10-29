import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/article_webview_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class ArticleItem extends StatelessWidget {
  final Article article;

  const ArticleItem({super.key, required this.article});

  void _openUrl(BuildContext context) async {
    if (kIsWeb) {
      // Web 이면 새 탭으로 열기
      final uri = Uri.parse(article.siteUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      // 모바일이면 WebViewPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ArticleWebviewPage(url: article.siteUrl, title: article.title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ← 탭 가능하게 InkWell로 감쌈
      onTap: () => _openUrl(context),
      child: Container(
        height: 136,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
        decoration: BoxDecoration(
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
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(article.createDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _siteMapping(article.siteName),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.star_border,
              color: Color.fromARGB(255, 158, 158, 158),
              size: 28,
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
