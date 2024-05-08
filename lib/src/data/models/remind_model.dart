import 'package:hive/hive.dart';

part 'remind_model.g.dart';

enum RepeatType {
  noRepeat,
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

@HiveType(typeId: 3)
class RemindModel {
  @HiveField(0)
  final DateTime? date;

  @HiveField(1)
  final RepeatType? repeatType;

  @HiveField(2)
  final CustomRemindEvent? customRemindEvent;

  @HiveField(3)
  final bool? markAsDone;

  RemindModel({
    required this.date,
    this.repeatType,
    this.customRemindEvent,
    this.markAsDone = false,
  });

  factory RemindModel.fromMap(Map<String, dynamic> data) => RemindModel(
        date: DateTime.tryParse(data['date'].toString()),
        repeatType: RepeatType.values[(data['repeatType'] as int?) ?? 0],
        markAsDone: data['markAsDone'] as bool?,
        customRemindEvent: data["customremindEvent"] != null
            ? CustomRemindEvent.fromMap(
                data["customremindEvent"] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toMap() {
    return {
      'date': date?.toIso8601String(),
      'repeatType': repeatType?.index,
      'customRemindEvent': customRemindEvent?.toMap(),
      'markAsDone': markAsDone,
    };
  }
}

@HiveType(typeId: 2)
class CustomRemindEvent {
  @HiveField(0)
  final int everyNDay;

  @HiveField(1)
  final bool? forever;

  @HiveField(2)
  final bool? until;

  @HiveField(3)
  final DateTime? untilDate;

  @HiveField(4)
  final bool? forRepeat;

  @HiveField(5)
  final int? forRepeatTime;

  CustomRemindEvent({
    this.everyNDay = 1,
    this.forever,
    this.until,
    this.untilDate,
    this.forRepeat,
    this.forRepeatTime,
  });

  factory CustomRemindEvent.fromMap(Map<String, dynamic> data) {
    return CustomRemindEvent(
      everyNDay: data['everyNDay'] ?? 1,
      forever: data['forever'],
      until: data['until'],
      untilDate:
          data['untilDate'] != null ? DateTime.parse(data['untilDate']) : null,
      forRepeat: data['forRepeat'],
      forRepeatTime: data['forRepeatTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'everyNDay': everyNDay,
      'forever': forever,
      'until': until,
      'untilDate': untilDate,
      'forRepeat': forRepeat,
      'forRepeatTime': forRepeatTime,
    };
  }
}
