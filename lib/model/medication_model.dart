class Medication {
  int? id; // Nullable for database reasons
  String name;
  String dosage;
  String additionalInfo;
  String imageUrl; // Required field, can be empty

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.additionalInfo,
    required this.imageUrl, // Marked as required
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'additionalInfo': additionalInfo,
      'imageUrl': imageUrl, // Always present
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      additionalInfo: json['additionalInfo'],
      imageUrl: json['imageUrl'],
    );
  }
}
