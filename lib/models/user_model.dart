class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String designation;
  final String companyName;
  final String bio;
  final String photoUrl;

  UserProfile({
    required this.uid,
    this.displayName = '',
    this.email = '',
    this.phoneNumber = '',
    this.designation = '',
    this.companyName = '',
    this.bio = '',
    this.photoUrl = '',
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      designation: map['designation'] ?? '',
      companyName: map['companyName'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'designation': designation,
      'companyName': companyName,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? designation,
    String? companyName,
    String? bio,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      designation: designation ?? this.designation,
      companyName: companyName ?? this.companyName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
