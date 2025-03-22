class NGO {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? websiteUrl;
  final String? contactEmail;
  final String? contactPhone;
  
  NGO({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.websiteUrl,
    this.contactEmail,
    this.contactPhone,
  });
  
  factory NGO.fromJson(Map<String, dynamic> json) {
    return NGO(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
    };
  }
}