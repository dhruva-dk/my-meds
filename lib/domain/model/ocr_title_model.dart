//model for OCR title - just has one string for the title

class OCRTitle {
  final String title;
  final String imagePath;

  OCRTitle({
    required this.title,
    required this.imagePath,
  });

  factory OCRTitle.fromMap(Map<String, dynamic> json) {
    return OCRTitle(
      title: json['title'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'imagePath': imagePath,
      };
}
