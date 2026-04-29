class NewsModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final String publishedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  factory NewsModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NewsModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      source: data['source'] ?? '',
      publishedAt: data['publishedAt'] ?? '',
    );
  }

  // Published date format
  String get formattedDate {
    try {
      final date = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}
