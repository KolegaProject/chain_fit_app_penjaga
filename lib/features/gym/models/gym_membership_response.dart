class GymMembershipResponse {
  GymMembershipResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final List<GymMembership> data;

  factory GymMembershipResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? <dynamic>[];

    return GymMembershipResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: dataJson
          .map((item) => GymMembership.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GymMembership {
  GymMembership({
    required this.id,
    required this.status,
    required this.masaAktifHari,
    required this.user,
  });

  final int id;
  final String status;
  final int masaAktifHari;
  final GymMembershipUser? user;

  String get userName {
    final name = user?.name ?? '';
    if (name.trim().isNotEmpty) {
      return name;
    }
    return 'Member';
  }

  String get userEmail => user?.email ?? '-';

  factory GymMembership.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return GymMembership(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      masaAktifHari: (json['masaAktifHari'] as num?)?.toInt() ?? 0,
      user: userJson is Map<String, dynamic>
          ? GymMembershipUser.fromJson(userJson)
          : null,
    );
  }
}

class GymMembershipUser {
  GymMembershipUser({required this.name, required this.email});

  final String name;
  final String email;

  factory GymMembershipUser.fromJson(Map<String, dynamic> json) {
    return GymMembershipUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '-',
    );
  }
}
