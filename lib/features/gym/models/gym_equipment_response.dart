class GymEquipmentDetailResponse {
  GymEquipmentDetailResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final GymEquipment data;

  factory GymEquipmentDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataJson =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return GymEquipmentDetailResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: GymEquipment.fromJson(dataJson),
    );
  }
}

class GymEquipmentResponse {
  GymEquipmentResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final List<GymEquipment> data;

  factory GymEquipmentResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? <dynamic>[];

    return GymEquipmentResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: dataJson
          .map((item) => GymEquipment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GymEquipment {
  GymEquipment({
    required this.id,
    required this.gymId,
    required this.name,
    required this.healthStatus,
    required this.photo,
    required this.videoUrl,
    required this.description,
    required this.jumlah,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int gymId;
  final String name;
  final String healthStatus;
  final String photo;
  final String videoUrl;
  final String description;
  final int jumlah;
  final String createdAt;
  final String updatedAt;

  factory GymEquipment.fromJson(Map<String, dynamic> json) {
    return GymEquipment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      gymId: (json['gymId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
      healthStatus: json['healthStatus'] as String? ?? '-',
      photo: json['photo'] as String? ?? '',
      videoUrl: json['videoURL'] as String? ?? '',
      description: json['description'] as String? ?? '-',
      jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '-',
      updatedAt: json['updatedAt'] as String? ?? '-',
    );
  }
}
