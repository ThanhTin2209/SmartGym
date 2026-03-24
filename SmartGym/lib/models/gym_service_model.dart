class GymService {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMonths;
  final String imageUrl;

  GymService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    required this.imageUrl,
  });

  factory GymService.fromJson(Map<String, dynamic> json) {
    return GymService(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMonths: json['durationMonths'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class UserSubscription {
  final int id;
  final int gymServiceId;
  final String status;
  final String? txHash;
  final DateTime? endDate;
  final GymService? service;

  UserSubscription({
    required this.id,
    required this.gymServiceId,
    required this.status,
    this.txHash,
    this.endDate,
    this.service,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      gymServiceId: json['gymServiceId'],
      status: json['status'],
      txHash: json['txHash'],
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      service: json['gymService'] != null ? GymService.fromJson(json['gymService']) : null,
    );
  }
}
