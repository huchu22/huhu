class Article {
  final String title;
  final String siteUrl;
  final DateTime createDate;
  final String siteName;

  Article({
    required this.title,
    required this.siteUrl,
    required this.createDate,
    required this.siteName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      siteUrl: json['siteUrl'] ?? '',
      createDate: json['creationDate'] != null
          ? DateTime.tryParse(json['creationDate']) ?? DateTime.now()
          : DateTime.now(),
      siteName: json['siteName'] ?? '',
    );
  }
}
