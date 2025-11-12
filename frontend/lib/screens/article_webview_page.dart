import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebviewPage extends StatefulWidget {
  final String url;
  final String title;
  final String siteName;

  const ArticleWebviewPage({
    super.key,
    required this.url,
    required this.title,
    required this.siteName,
  });

  @override
  State<ArticleWebviewPage> createState() => _ArticleWebviewPageState();
}

class _ArticleWebviewPageState extends State<ArticleWebviewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.siteName)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
