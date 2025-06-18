class Studio {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String location;
  final List<String> trendingImages;
  final List<StudioService> services;
  final bool isBlocked;
  final String? blockedReason;

  Studio({
    required this.id,
    this.userId = '',
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.trendingImages,
    required this.services,
    this.isBlocked = false,
    this.blockedReason,
  });

  static Studio empty() {
    return Studio(
      id: '',
      userId: '',
      name: '',
      phone: '',
      email: '',
      location: '',
      trendingImages: [],
      services: [],
      isBlocked: false,
      blockedReason: null,
    );
  }

  factory Studio.fromMap(Map<String, dynamic> map) {
    return Studio(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      trendingImages: List<String>.from(map['trendingImages'] ?? []),
      services: (map['services'] as List<dynamic>?)
              ?.map((service) => StudioService.fromMap(service))
              .toList() ??
          [],
      isBlocked: map['isBlocked'] ?? false,
      blockedReason: map['blockedReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'location': location,
      'trendingImages': trendingImages,
      'services': services.map((service) => service.toMap()).toList(),
      'isBlocked': isBlocked,
      'blockedReason': blockedReason,
    };
  }

  Studio copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? location,
    List<String>? trendingImages,
    List<StudioService>? services,
    bool? isBlocked,
    String? blockedReason,
  }) {
    return Studio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      trendingImages: trendingImages ?? this.trendingImages,
      services: services ?? this.services,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedReason: blockedReason ?? this.blockedReason,
    );
  }
}

class StudioService {
  final String id;
  final String name;
  final String image;
  final List<ServicePackage> packages;

  StudioService({
    this.id = '',
    required this.name,
    this.image = '',
    required this.packages,
  });

  static StudioService empty() {
    return StudioService(
      id: '',
      name: '',
      image: '',
      packages: [],
    );
  }

  factory StudioService.fromMap(Map<String, dynamic> map) {
    return StudioService(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      packages: (map['packages'] as List<dynamic>?)
              ?.map((package) => ServicePackage.fromMap(package))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'packages': packages.map((package) => package.toMap()).toList(),
    };
  }

  StudioService copyWith({
    String? id,
    String? name,
    String? image,
    List<ServicePackage>? packages,
  }) {
    return StudioService(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      packages: packages ?? this.packages,
    );
  }
}

class ServicePackage {
  final String id;
  final String name;
  final int photoCount;
  final int workingHours;
  final int photographers;
  final double rate;

  ServicePackage({
    this.id = '',
    required this.name,
    required this.photoCount,
    required this.workingHours,
    required this.photographers,
    required this.rate,
  });

  static ServicePackage empty() {
    return ServicePackage(
      id: '',
      name: '',
      photoCount: 0,
      workingHours: 0,
      photographers: 0,
      rate: 0.0,
    );
  }

  factory ServicePackage.fromMap(Map<String, dynamic> map) {
    return ServicePackage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoCount: map['photoCount'] ?? 0,
      workingHours: map['workingHours'] ?? 0,
      photographers: map['photographers'] ?? 0,
      rate: (map['rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoCount': photoCount,
      'workingHours': workingHours,
      'photographers': photographers,
      'rate': rate,
    };
  }

  ServicePackage copyWith({
    String? id,
    String? name,
    int? photoCount,
    int? workingHours,
    int? photographers,
    double? rate,
  }) {
    return ServicePackage(
      id: id ?? this.id,
      name: name ?? this.name,
      photoCount: photoCount ?? this.photoCount,
      workingHours: workingHours ?? this.workingHours,
      photographers: photographers ?? this.photographers,
      rate: rate ?? this.rate,
    );
  }
}
