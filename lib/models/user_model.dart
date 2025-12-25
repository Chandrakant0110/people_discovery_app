import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a user profile in the app
class UserModel {
  final String userId;
  final String phoneNumber;
  final String displayName;
  final String? email;
  final String? profilePhotoUrl;
  final String profession;
  final UserLocation location;
  final String? bio;
  final String? website;
  final SocialLinks socialLinks;
  final int projectCount;
  final int? yearsOfExperience;
  final String? gender; // 'male' | 'female' | 'other' | 'prefer_not_to_say'
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.phoneNumber,
    required this.displayName,
    this.email,
    this.profilePhotoUrl,
    required this.profession,
    required this.location,
    this.bio,
    this.website,
    required this.socialLinks,
    this.projectCount = 0,
    this.yearsOfExperience,
    this.gender,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
    this.isActive = true,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'],
      profilePhotoUrl: data['profilePhotoUrl'],
      profession: data['profession'] ?? '',
      location: UserLocation.fromMap(data['location'] ?? {}),
      bio: data['bio'],
      website: data['website'],
      socialLinks: SocialLinks.fromMap(data['socialLinks'] ?? {}),
      projectCount: data['projectCount'] ?? 0,
      yearsOfExperience: data['yearsOfExperience'],
      gender: data['gender'],
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert UserModel to Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      if (email != null) 'email': email,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      'profession': profession,
      'location': location.toMap(),
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      'socialLinks': socialLinks.toMap(),
      'projectCount': projectCount,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      if (gender != null) 'gender': gender,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastSeen != null) 'lastSeen': Timestamp.fromDate(lastSeen!),
      'isActive': isActive,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? displayName,
    String? email,
    String? profilePhotoUrl,
    String? profession,
    UserLocation? location,
    String? bio,
    String? website,
    SocialLinks? socialLinks,
    int? projectCount,
    int? yearsOfExperience,
    String? gender,
    bool? isVerified,
    DateTime? updatedAt,
    DateTime? lastSeen,
    bool? isActive,
  }) {
    return UserModel(
      userId: userId,
      phoneNumber: phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profession: profession ?? this.profession,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      projectCount: projectCount ?? this.projectCount,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      gender: gender ?? this.gender,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// User location model
class UserLocation {
  final String city;
  final String? state;
  final String country;
  final GeoPoint? coordinates;

  UserLocation({
    required this.city,
    this.state,
    required this.country,
    this.coordinates,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      city: map['city'] ?? '',
      state: map['state'],
      country: map['country'] ?? '',
      coordinates: map['coordinates'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      if (state != null) 'state': state,
      'country': country,
      if (coordinates != null) 'coordinates': coordinates,
    };
  }
}

/// Social media links model
class SocialLinks {
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String? behance;
  final String? dribbble;
  final String? github;

  SocialLinks({
    this.instagram,
    this.linkedin,
    this.twitter,
    this.behance,
    this.dribbble,
    this.github,
  });

  factory SocialLinks.fromMap(Map<String, dynamic> map) {
    return SocialLinks(
      instagram: map['instagram'],
      linkedin: map['linkedin'],
      twitter: map['twitter'],
      behance: map['behance'],
      dribbble: map['dribbble'],
      github: map['github'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (instagram != null && instagram!.isNotEmpty) 'instagram': instagram,
      if (linkedin != null && linkedin!.isNotEmpty) 'linkedin': linkedin,
      if (twitter != null && twitter!.isNotEmpty) 'twitter': twitter,
      if (behance != null && behance!.isNotEmpty) 'behance': behance,
      if (dribbble != null && dribbble!.isNotEmpty) 'dribbble': dribbble,
      if (github != null && github!.isNotEmpty) 'github': github,
    };
  }
}
