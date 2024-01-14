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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'additionalInfo': additionalInfo,
      'imageUrl': imageUrl, // Always present
    };
  }

  factory Medication.fromMap(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      additionalInfo: json['additionalInfo'],
      imageUrl: json['imageUrl'],
    );
  }

  //copyWith method for updating medication
  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    String? additionalInfo,
    String? imageUrl,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
