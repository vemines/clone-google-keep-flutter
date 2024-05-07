import 'package:hive/hive.dart';

part 'label_model.g.dart';

@HiveType(typeId: 10)
class LabelModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String label;

  LabelModel({
    this.id,
    required this.label,
  });

  factory LabelModel.fromMap(Map<String, dynamic> data) => LabelModel(
        id: data['id'] as String?,
        label: data['label'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LabelModel && label == other.label;
  }

  @override
  int get hashCode {
    return label.hashCode;
  }
}
