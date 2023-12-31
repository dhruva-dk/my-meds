class UserProfile {
  int id;
  String name;
  String dob; // Date of Birth as String
  String pcp; // Primary Care Physician
  String healthConditions;

  UserProfile(
      {this.id = 0,
      required this.name,
      required this.dob,
      this.pcp = '',
      this.healthConditions = ''});

  // Convert a UserProfile instance into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'pcp': pcp,
      'healthConditions': healthConditions,
    };
  }

  // Create a UserProfile from a map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      dob: map['dob'],
      pcp: map['pcp'] ?? '',
      healthConditions: map['healthConditions'] ?? '',
    );
  }

  // Add a copy method
  UserProfile copy({
    int? id,
    String? name,
    String? dob,
    String? pcp,
    String? healthConditions,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        dob: dob ?? this.dob,
        pcp: pcp ?? this.pcp,
        healthConditions: healthConditions ?? this.healthConditions,
      );
}
