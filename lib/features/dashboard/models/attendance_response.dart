class AttendanceResponse {
  AttendanceResponse({
    required this.code,
    required this.status,
    required this.recordsTotal,
    required this.data,
  });

  final int code;
  final String status;
  final int recordsTotal;
  final List<AttendanceEntry> data;

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as List<dynamic>? ?? <dynamic>[];

    return AttendanceResponse(
      code: (json['code'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '-',
      recordsTotal: (json['recordsTotal'] as num?)?.toInt() ?? 0,
      data: dataJson
          .map((item) => AttendanceEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttendanceEntry {
  AttendanceEntry({
    required this.id,
    required this.membershipId,
    required this.gymId,
    required this.checkInAt,
    required this.checkOutAt,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.membership,
  });

  final int id;
  final int membershipId;
  final int gymId;
  final String checkInAt;
  final String? checkOutAt;
  final int createdById;
  final String createdAt;
  final String updatedAt;
  final AttendanceMembership? membership;

  int? get memberUserId => membership?.user?.id;

  String get memberName {
    final name = membership?.user?.name ?? '';
    if (name.trim().isNotEmpty) {
      return name;
    }

    if (membershipId > 0) {
      return 'Member #$membershipId';
    }

    return 'Member';
  }

  String get memberProfileImage => membership?.user?.profileImage ?? '';

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    final membershipJson = json['membership'];

    return AttendanceEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      membershipId: (json['membershipId'] as num?)?.toInt() ?? 0,
      gymId: (json['gymId'] as num?)?.toInt() ?? 0,
      checkInAt: json['checkInAt'] as String? ?? '-',
      checkOutAt: json['checkOutAt'] as String?,
      createdById: (json['createdById'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '-',
      updatedAt: json['updatedAt'] as String? ?? '-',
      membership: membershipJson is Map<String, dynamic>
          ? AttendanceMembership.fromJson(membershipJson)
          : null,
    );
  }
}

class AttendanceMembership {
  AttendanceMembership({required this.user});

  final AttendanceUser? user;

  factory AttendanceMembership.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return AttendanceMembership(
      user: userJson is Map<String, dynamic>
          ? AttendanceUser.fromJson(userJson)
          : null,
    );
  }
}

class AttendanceUser {
  AttendanceUser({
    required this.id,
    required this.name,
    required this.profileImage,
  });

  final int id;
  final String name;
  final String profileImage;

  factory AttendanceUser.fromJson(Map<String, dynamic> json) {
    return AttendanceUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
    );
  }
}
