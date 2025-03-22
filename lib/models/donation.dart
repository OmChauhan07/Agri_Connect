class Donation {
  final String id;
  final String consumerId;
  final String ngoId;
  final double amount;
  final String? certificateId;
  final DateTime donationDate;
  final String? ngoName; // For UI display, not stored in database
  final String? ngoLogo; // For UI display, not stored in database

  Donation({
    required this.id,
    required this.consumerId,
    required this.ngoId,
    required this.amount,
    this.certificateId,
    required this.donationDate,
    this.ngoName,
    this.ngoLogo,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      consumerId: json['consumer_id'],
      ngoId: json['ngo_id'],
      amount: json['amount'].toDouble(),
      certificateId: json['certificate_id'],
      donationDate: DateTime.parse(json['donation_date']),
      ngoName: json['ngo_name'],
      ngoLogo: json['ngo_logo'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'consumer_id': consumerId,
      'ngo_id': ngoId,
      'amount': amount,
      'donation_date': donationDate.toIso8601String(),
    };

    // Only include id if it's not empty
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    // Only include certificate_id if it's not null
    if (certificateId != null) {
      map['certificate_id'] = certificateId;
    }

    return map;
  }

  // Helper method to create a new donation object
  static Donation create({
    required String consumerId,
    required String ngoId,
    required double amount,
    String? ngoName,
    String? ngoLogo,
  }) {
    // Use an empty string for id - it will be replaced with a UUID in the database service
    return Donation(
      id: '', // Will be replaced with a UUID in database_service.dart
      consumerId: consumerId,
      ngoId: ngoId,
      amount: amount,
      donationDate: DateTime.now(),
      ngoName: ngoName,
      ngoLogo: ngoLogo,
    );
  }
}
