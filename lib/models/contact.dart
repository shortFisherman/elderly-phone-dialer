class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String photoPath;
  final int colorIndex;

  const Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.photoPath,
    required this.colorIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'photoPath': photoPath,
        'colorIndex': colorIndex,
      };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
        photoPath: json['photoPath'] as String,
        colorIndex: json['colorIndex'] as int,
      );

  Contact copyWith({
    String? name,
    String? phoneNumber,
    String? photoPath,
    int? colorIndex,
  }) =>
      Contact(
        id: id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        photoPath: photoPath ?? this.photoPath,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}
