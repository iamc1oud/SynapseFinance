import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({required super.id, required super.name});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
