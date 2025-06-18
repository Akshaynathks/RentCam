class Offer {
  final String id;
  final String couponCode;
  final double percentage;
  final String? imageUrl;

  Offer({
    required this.id,
    required this.couponCode,
    required this.percentage,
    this.imageUrl, required String description,
  });

  Map<String, dynamic> toMap() {
    return {
      'couponCode': couponCode,
      'percentage': percentage,
      'imageUrl': imageUrl,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map, String id) {
    return Offer(
      id: id,
      couponCode: map['couponCode'] as String,
      percentage: map['percentage'] as double,
      imageUrl: map['imageUrl'] as String?, description: '',
    );
  }
}