import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/setting_model.dart';

class SettingsService {
  final String uid;
  SettingsService(this.uid) {}

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateSettingField(
      String uid, String field, dynamic value) async {
    await _firestore.collection('auths').doc(uid).update({
      'settings.$field': value,
    });
  }
}

SettingsModel defaultSettings = SettingsModel(
  addNoteToBottom: false,
  moveCheckedToBottom: false,
  displayRichLink: false,
  theme: 'Dark',
  morningRemind: "08:00",
  afternoonRemind: "13:00",
  eveningRemind: "18:00",
  enableSharing: false,
  language: "en",
);
