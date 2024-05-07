import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 6)
class TodoModel {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool checked;

  TodoModel({
    required this.text,
    required this.checked,
  });

  factory TodoModel.fromMap(Map<String, dynamic> data) => TodoModel(
        text: data['text'] as String,
        checked: data['checked'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'text': text,
        'checked': checked,
      };
}
