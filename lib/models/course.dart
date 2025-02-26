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
      id: json['id'] ?? 0, // Provide a default value if id is null
      name: json['name'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      imagePath: json['imagePath'] as String?,
      pdfPath: json['pdfPath'] as String?,
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
