class Student {
  String? message;
  int? status;
  StudentData? studentData;

  Student({
    required this.message,
    required this.status,
    required this.studentData,
  });
}

class StudentData {
  String id;
  String name;
  String studentClass;
  String faculty;

  StudentData(
      {required this.id,
      required this.name,
      required this.studentClass,
      required this.faculty});
}
