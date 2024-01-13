//model for OCR title - just has one string for the title

class OCRTitle {
  final String title;

  OCRTitle({
    required this.title,
  });

  factory OCRTitle.fromJson(Map<String, dynamic> json) {
    return OCRTitle(
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}
