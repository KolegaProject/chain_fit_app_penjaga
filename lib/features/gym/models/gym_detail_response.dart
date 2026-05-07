class GymDetailResponse {
  GymDetailResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final GymDetail data;

  factory GymDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataJson =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return GymDetailResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: GymDetail.fromJson(dataJson),
    );
  }
}

class GymDetail {
  GymDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.maxCapacity,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.jamOperasional,
    required this.facility,
    required this.tag,
    required this.ownerId,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
    required this.gymImage,
  });

  final int id;
  final String name;
  final String description;
  final int maxCapacity;
  final String latitude;
  final String longitude;
  final String address;
  final String jamOperasional;
  final List<String> facility;
  final String tag;
  final int ownerId;
  final String verified;
  final String createdAt;
  final String updatedAt;
  final List<GymImage> gymImage;

  factory GymDetail.fromJson(Map<String, dynamic> json) {
    final facilityJson = json['facility'] as List<dynamic>? ?? <dynamic>[];
    final gymImages = json['gymImage'] as List<dynamic>? ?? <dynamic>[];

    return GymDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
      description: json['description'] as String? ?? '-',
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
      latitude: json['latitude'] as String? ?? '-',
      longitude: json['longitude'] as String? ?? '-',
      address: json['address'] as String? ?? '-',
      jamOperasional: json['jamOperasional'] as String? ?? '-',
      facility: facilityJson.map((item) => item.toString()).toList(),
      tag: json['tag'] as String? ?? '-',
      ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as String? ?? '-',
      createdAt: json['createdAt'] as String? ?? '-',
      updatedAt: json['updatedAt'] as String? ?? '-',
      gymImage: gymImages
          .map((image) => GymImage.fromJson(image as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GymImage {
  GymImage({required this.id, required this.url});

  final int id;
  final String url;

  factory GymImage.fromJson(Map<String, dynamic> json) {
    return GymImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
    );
  }
}
