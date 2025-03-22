import '../utils/constants.dart';

class Rating {
  final String id;
  final String userId;
  final String targetId; // Either product ID or farmer ID
  final RatingType type;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.type,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      targetId: json['target_id'],
      type: RatingType.values.byName(json['type']),
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'type': type.name,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
