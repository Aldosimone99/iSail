class Course {
  final String name;
  final DateTime deadline;

  Course({required this.name, required this.deadline});

  get description => null;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'],
      deadline: DateTime.parse(json['deadline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'deadline': deadline.toIso8601String(),
    };
  }
}
