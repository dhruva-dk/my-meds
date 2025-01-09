class Medication {
  final int? id;
  final int profileId;
  final String name;
  final String dosage;
  final String additionalInfo;
  String
      imageUrl; //just stores the image's file name. the documents directory should be added dynamically.

  Medication({
    this.id,
    required this.profileId,
    required this.name,
    required this.dosage,
    required this.additionalInfo,
    this.imageUrl = '',
  });

  // Add copyWith method for easy updates
  Medication copyWith({
    int? id,
    int? profileId,
    String? name,
    String? dosage,
    String? additionalInfo,
    String? imageUrl,
  }) {
    return Medication(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'profile_id': profileId,
        'name': name,
        'dosage': dosage,
        'additionalInfo': additionalInfo,
        'imageUrl': imageUrl,
      };

  static Medication fromMap(Map<String, dynamic> map) => Medication(
        id: map['id'],
        profileId: map['profile_id'],
        name: map['name'],
        dosage: map['dosage'],
        additionalInfo: map['additionalInfo'],
        imageUrl: map['imageUrl'] ?? '',
      );
}
