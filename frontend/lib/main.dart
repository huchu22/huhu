import 'package:flutter/material.dart';
import 'screens/main_page.dart';
// WebView platform packages are not needed in main.dart; import them where used.

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 플랫폼별 WebView 초기화 (모바일)
  // NOTE:
  // Older tutorials used `WebView.platform = ...` to set platform implementations.
  // In recent versions of `webview_flutter` (v4+), the API changed and the
  // `WebView` symbol / `WebView.platform` may no longer be available.
  // The plugin now prefers the newer controller/widget APIs and typically
  // performs platform initialization automatically. To avoid analyzer/compile
  // errors (Undefined name 'WebView'), we skip manual platform initialization here.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'huhu Article Feed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
