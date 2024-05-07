import 'package:hive/hive.dart';

part 'setting_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel {
  @HiveField(0)
  bool addNoteToBottom;

  @HiveField(1)
  bool moveCheckedToBottom;

  @HiveField(2)
  bool displayRichLink;

  @HiveField(3)
  String theme;

  @HiveField(4)
  String morningRemind;

  @HiveField(5)
  String afternoonRemind;

  @HiveField(6)
  String eveningRemind;

  @HiveField(7)
  bool enableSharing;

  @HiveField(8)
  String language;

  SettingsModel({
    required this.addNoteToBottom,
    required this.moveCheckedToBottom,
    required this.displayRichLink,
    required this.theme,
    required this.morningRemind,
    required this.afternoonRemind,
    required this.eveningRemind,
    required this.enableSharing,
    required this.language,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> data) => SettingsModel(
        addNoteToBottom: data['addNoteToBottom'] as bool,
        moveCheckedToBottom: data['moveCheckedToBottom'] as bool,
        displayRichLink: data['displayRichLink'] as bool,
        theme: data['theme'] as String,
        morningRemind: data['morningRemind'] as String,
        afternoonRemind: data['afternoonRemind'] as String,
        eveningRemind: data['eveningRemind'] as String,
        enableSharing: data['enableSharing'] as bool,
        language: data['language'] as String,
      );

  Map<String, dynamic> toMap() {
    return {
      'addNoteToBottom': addNoteToBottom,
      'moveCheckedToBottom': moveCheckedToBottom,
      'displayRichLink': displayRichLink,
      'theme': theme,
      'morningRemind': morningRemind,
      'afternoonRemind': afternoonRemind,
      'eveningRemind': eveningRemind,
      'enableSharing': enableSharing,
      'language': language,
    };
  }
}
