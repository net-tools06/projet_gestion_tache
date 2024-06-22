class Todo {
  int? id;
  String name;
  String description;
  String status;

  Todo({
    this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
    };
  }
}