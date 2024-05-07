import 'package:hive/hive.dart';

part 'image_model.g.dart';

@HiveType(typeId: 9)
class ImageModel {
  @HiveField(0)
  String url;

  @HiveField(1)
  bool isDrawPad;

  ImageModel({
    required this.url,
    required this.isDrawPad,
  });

  factory ImageModel.fromMap(Map<String, dynamic> data) => ImageModel(
        url: data['url'] as String,
        isDrawPad: data['isDrawPad'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'url': url,
        'isDrawPad': isDrawPad,
      };
}
