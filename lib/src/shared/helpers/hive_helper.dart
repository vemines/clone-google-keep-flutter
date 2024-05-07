import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/note_model.dart';
import '../../data/models/remind_model.dart';
import '../../data/models/setting_model.dart';
import '../../data/models/shared_note_model.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/todo_model.dart';

class HiveHelper {
  HiveHelper._() {
    Hive.registerAdapter(AuthModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(TodoModelAdapter());
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(SharedNoteModelAdapter());
    Hive.registerAdapter(CustomRemindEventAdapter());
    Hive.registerAdapter(RemindModelAdapter());
  }
  static final HiveHelper _instance = HiveHelper._();
  static HiveHelper get instance => _instance;
  final String _defaultBox = 'storage';

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.openBox(_defaultBox);
  }

  Future<void> put({
    String? box,
    required String key,
    required dynamic value,
  }) async {
    final hiveBox = await Hive.openBox(box ?? _defaultBox);
    await hiveBox.put(key, value);
  }

  Future<dynamic> get({
    String? box,
    required String key,
  }) async {
    final hiveBox = await Hive.openBox(box ?? _defaultBox);
    var result = await hiveBox.get(key);
    return result;
  }

  Future<void> remove({
    String? box,
    required String key,
  }) async {
    final hiveBox = await Hive.box(box ?? _defaultBox);
    await hiveBox.delete(key);
  }
}
