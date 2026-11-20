class Course {
  final int? id;
  final String? ownerId;
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    this.id,
    this.ownerId,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final creditsValue = json['credits'];

    return Course(
      id: idValue is num ? idValue.toInt() : null,
      ownerId: json['owner_id']?.toString(),
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      credits: creditsValue is num ? creditsValue.toInt() : 0,
      status: json['status']?.toString() ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'title': title, 'credits': credits, 'status': status};
  }

  bool isOwnedBy(String userId) {
    return ownerId == userId;
  }
}
