class Course {
  final int id;
  final String name;
  final DateTime deadline;
  String? imagePath; // Add imagePath field
  String? pdfPath; // Add pdfPath field

  Course({required this.id, required this.name, required this.deadline, this.imagePath, this.pdfPath});

  get description => null;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      deadline: DateTime.parse(json['deadline']),
      imagePath: json['imagePath'], // Parse imagePath from JSON
      pdfPath: json['pdfPath'], // Parse pdfPath from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deadline': deadline.toIso8601String(),
      'imagePath': imagePath, // Include imagePath in JSON
      'pdfPath': pdfPath, // Include pdfPath in JSON
    };
  }
}
