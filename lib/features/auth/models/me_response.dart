class MeResponse {
  MeResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final MeData data;

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final dataJson =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return MeResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: MeData.fromJson(dataJson),
    );
  }
}

class MeData {
  MeData({required this.user, required this.gyms, required this.defaultGymId});

  final MeUser user;
  final List<MeGym> gyms;
  final int? defaultGymId;

  factory MeData.fromJson(Map<String, dynamic> json) {
    final gymsJson = json['gyms'] as List<dynamic>? ?? <dynamic>[];

    return MeData(
      user: MeUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      gyms: gymsJson
          .map((gym) => MeGym.fromJson(gym as Map<String, dynamic>))
          .toList(),
      defaultGymId: (json['defaultGymId'] as num?)?.toInt(),
    );
  }
}

class MeUser {
  MeUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.profileImage,
    required this.name,
  });

  final int id;
  final String username;
  final String email;
  final String role;
  final String profileImage;
  final String name;

  factory MeUser.fromJson(Map<String, dynamic> json) {
    return MeUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
      role: json['role'] as String? ?? '-',
      profileImage: json['profileImage'] as String? ?? '',
      name: json['name'] as String? ?? '-',
    );
  }
}

class MeGym {
  MeGym({required this.id, required this.name});

  final int id;
  final String name;

  factory MeGym.fromJson(Map<String, dynamic> json) {
    return MeGym(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '-',
    );
  }
}
