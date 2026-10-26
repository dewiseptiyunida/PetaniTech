class ReviewModel {
  final String id;
  final String orderId;
  final String productName;
  final String? variant;
  final String userName;
  final int rating;
  final int courierRating;
  final String comment;
  final List<String> photoPaths;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.productName,
    this.variant,
    required this.userName,
    required this.rating,
    this.courierRating = 5,
    required this.comment,
    this.photoPaths = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productName': productName,
      'variant': variant,
      'userName': userName,
      'rating': rating,
      'courierRating': courierRating,
      'comment': comment,
      'photoPaths': photoPaths,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      variant: json['variant']?.toString(),
      userName: json['userName']?.toString() ?? 'Pengguna PetaniTech',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      courierRating: (json['courierRating'] as num?)?.toInt() ?? 5,
      comment: json['comment']?.toString() ?? '',
      photoPaths: (json['photoPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
