// TAHAP 8: Membuat Model Course
class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code']?.toString() ?? json['title']?.toString() ?? 'UNKNOWN',
      title: json['title']?.toString() ?? 'No Title',
      credits: (json['credits'] != null) ? int.tryParse(json['credits'].toString()) ?? 0 : 0,
      status: json['status']?.toString() ?? 'unknown',
    );
  }
}