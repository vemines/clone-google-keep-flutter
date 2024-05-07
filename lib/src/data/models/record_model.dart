import 'package:hive/hive.dart';

part 'record_model.g.dart';

@HiveType(typeId: 8)
class RecordModel {
  @HiveField(0)
  String? url;

  @HiveField(1)
  int? secondsDuration;

  RecordModel({
    this.url,
    this.secondsDuration,
  });

  Map<String, dynamic> toMap() => {
        'url': url,
        'secondsDuration': secondsDuration,
      };

  factory RecordModel.fromMap(Map<String, dynamic> data) => RecordModel(
        url: data['url'] as String?,
        secondsDuration: data['secondsDuration'] as int?,
      );
}
