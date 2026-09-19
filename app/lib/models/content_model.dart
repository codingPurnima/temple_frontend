class HomeContent {
  final String? title;
  final String? subtitle;
  final String? content;

  HomeContent({
    this.title,
    this.subtitle,
    this.content,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'content': content,
  };
}

class DashboardImage {
  final int id;
  final String imageUrl;
  final int? displayOrder;

  DashboardImage({
    required this.id,
    required this.imageUrl,
    this.displayOrder,
  });

  factory DashboardImage.fromJson(Map<String, dynamic> json) {
    return DashboardImage(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      displayOrder: json['display_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_url': imageUrl,
    'display_order': displayOrder,
  };
}

class QuoteContent {
  final String? text;
  final String? imageUrl;

  QuoteContent({
    this.text,
    this.imageUrl,
  });

  factory QuoteContent.fromJson(Map<String, dynamic> json) {
    return QuoteContent(
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'image_url': imageUrl,
  };
}

class AppContent {
  final HomeContent home;
  final List<DashboardImage> dashboardImages;
  final QuoteContent quote;
  final DateTime? updatedAt;

  AppContent({
    required this.home,
    required this.dashboardImages,
    required this.quote,
    this.updatedAt,
  });

  factory AppContent.fromJson(Map<String, dynamic> json) {
    return AppContent(
      home: json['home'] != null
          ? HomeContent.fromJson(json['home'] as Map<String, dynamic>)
          : HomeContent(),
      dashboardImages: (json['dashboard_images'] as List<dynamic>?)
              ?.map((item) => DashboardImage.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      quote: json['quote'] != null
          ? QuoteContent.fromJson(json['quote'] as Map<String, dynamic>)
          : QuoteContent(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'home': home.toJson(),
    'dashboard_images': dashboardImages.map((e) => e.toJson()).toList(),
    'quote': quote.toJson(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
