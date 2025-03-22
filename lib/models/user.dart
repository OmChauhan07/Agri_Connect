enum UserRole { farmer, consumer }

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? profileImage;
  final UserRole role;
  final String? address;
  final double? rating;
  final int? totalRatings;
  final String? badgeType; // null, 'orange', 'green'

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.profileImage,
    required this.role,
    this.address,
    this.rating,
    this.totalRatings,
    this.badgeType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
      role: json['role'] == 'farmer' ? UserRole.farmer : UserRole.consumer,
      address: json['address'],
      rating: json['rating']?.toDouble(),
      totalRatings: json['total_ratings'],
      badgeType: json['badge_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'role': role == UserRole.farmer ? 'farmer' : 'consumer',
      'address': address,
      'rating': rating,
      'total_ratings': totalRatings,
      'badge_type': badgeType,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImage,
    UserRole? role,
    String? address,
    double? rating,
    int? totalRatings,
    String? badgeType,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      badgeType: badgeType ?? this.badgeType,
    );
  }
}
