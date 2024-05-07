import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'label_model.dart';
import 'setting_model.dart';

part 'auth_model.g.dart';

@HiveType(typeId: 7)
class AuthModel {
  @HiveField(0)
  String? uid;
  @HiveField(1)
  String? displayName;
  @HiveField(2)
  String? imageUrl;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? provider;
  @HiveField(5)
  SettingsModel? settings;
  @HiveField(6)
  List<String>? notesId;
  @HiveField(7)
  List<String>? sharedNotesId;
  @HiveField(8)
  DateTime? createAt;
  @HiveField(9)
  DateTime? lastSignInTime;
  @HiveField(10)
  List<LabelModel>? labels;

  AuthModel({
    this.uid,
    this.displayName,
    this.imageUrl,
    this.email,
    this.provider,
    this.settings,
    this.notesId,
    this.sharedNotesId,
    this.lastSignInTime,
    this.createAt,
    this.labels,
  });

  factory AuthModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data()!;
    return AuthModel(
      uid: json['uid'],
      displayName: json['displayName'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      provider: json['provider'],
      lastSignInTime: json['lastSignInTime'] != null
          ? (json['lastSignInTime'] as Timestamp).toDate()
          : null,
      createAt: json['createAt'] != null
          ? (json['createAt'] as Timestamp).toDate()
          : null,
      notesId: List<String>.from(json['notesId']),
      sharedNotesId: List<String>.from(json['sharedNotesId']),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((label) => LabelModel.fromMap(label))
          .toList(),
      settings: SettingsModel.fromMap(json['settings']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'imageUrl': imageUrl,
      'email': email,
      'provider': provider,
      'lastSignInTime': lastSignInTime,
      'notesId': List<String>.from(notesId!.map((e) => e)),
      'sharedNotesId': List<dynamic>.from(sharedNotesId!.map((e) => e)),
      'settings': settings!.toMap(),
      'labels': List<dynamic>.from(sharedNotesId!.map((e) => e)),
    };
  }
}
