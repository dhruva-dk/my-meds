class Medication {
  int id = 0;

  String name;
  String dosage;
  String additionalInfo;

  Medication(
      {this.id = 0,
      required this.name,
      required this.dosage,
      required this.additionalInfo});

  // Convert a Medication instance into a map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'additionalInfo': additionalInfo,
      'id': id,
    };
  }

  // Create a Medication from a map (from JSON)
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'],
      dosage: json['dosage'],
      additionalInfo: json['additionalInfo'],
      id: json['id'],
    );
  }
}
