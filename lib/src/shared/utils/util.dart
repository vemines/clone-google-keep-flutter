import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../constants/value.dart';
import '../helpers/hive_helper.dart';

HiveHelper _hiveHelper = HiveHelper.instance;

/// get uid user frome hive
Future<String?> getCurrentAuthUid() async {
  final String? uid = await _hiveHelper.get(
    key: "currentAuth",
  );
  print("getCurrentAuthUid------------------uid: $uid");
  return uid;
}

/// save uid user to hive
Future<void> setCurrentAuthUid(String uid) async {
  await _hiveHelper.put(
    key: "currentAuth",
    value: uid,
  );
}

/// "en-US" to Locale("en","US")
Locale toLocale(String s) {
  List<String> split = s.split("-");
  return Locale(split[0], split[1]);
}

/// "12:34" to TimeOfDay(hour: 12, minute: 34)
TimeOfDay stringToTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// TimeOfDay(hour: 12, minute: 34) to "12:34"
String timeOfDayToString(TimeOfDay time) {
  String hour = time.hour > 10 ? "${time.hour}" : "0${time.hour}";
  String minute = time.minute > 10 ? "${time.minute}" : "0${time.minute}";
  return '$hour:$minute';
}

/// 123 seconds to 2:03
String formatDuration([int? totalSeconds = 0]) {
  int hours = totalSeconds! ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  String paddedSeconds = seconds < 10 ? '0$seconds' : '$seconds';
  String paddedMinutes = minutes < 10 && hours > 1
      ? '0${minutes.toString().padLeft(2, '0')}'
      : '${minutes.toString().padLeft(2, '0')}';

  return hours > 0
      ? '$hours:$paddedMinutes:$paddedSeconds'
      : '$paddedMinutes:$paddedSeconds';
}

//
Future<XFile?> pickImage() async {
  final picker = ImagePicker();
  XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
  return imageFile;
}

CameraDescription? _camera;
Future<XFile?> takePhoto() async {
  if (_camera == null) {
    final cameras = await availableCameras();
    _camera = cameras.first;
  }
  CameraController controller =
      CameraController(_camera!, ResolutionPreset.max);
  await controller.initialize();
  final XFile imageFile = await controller.takePicture();
  return imageFile;
}

Future<void> saveUint8ListToChache(Uint8List data, String fileName) async {
  final appCacheDir = await getTemporaryDirectory();
  String filePath = '${appCacheDir.path}/$fileName';
  File file = File(filePath);
  await file.writeAsBytes(data);
}

String? cacheDir;
Future<String> cacheDirectory() async {
  if (cacheDir == null) {
    final directory = await getTemporaryDirectory();
    cacheDir = directory.path;
  }
  return cacheDir!;
}

String timestamp() => DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

String fileNameByTimestamp(String prefix, String ext) =>
    "${prefix}_${timestamp()}_${randomId()}.${ext}";

Future<String> saveUint8ListToCache(Uint8List data, String fileName) async {
  if (cacheDir == null) {
    cacheDir = await cacheDirectory();
  }
  String filePath = '$cacheDir/$fileName';
  File file = File(filePath);
  await file.writeAsBytes(data);
  return filePath;
}

Future<void> record(
    String savedPath, BuildContext context, Function(Duration?) onStop) async {
  final recorder = Record();
  await recorder.start(path: savedPath);
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  final snackBar = SnackBar(
    content: Text('Recording in progress...'),
    duration: Duration(hours: 24), // Make the SnackBar persistent
    action: SnackBarAction(
      label: 'Stop',
      onPressed: () async {
        final output = await recorder.stop();
        AudioPlayer audioPlayer = AudioPlayer();
        await audioPlayer.setSourceDeviceFile(output!);
        Duration? duration = await audioPlayer.getDuration();
        onStop(duration);

        scaffoldMessenger.hideCurrentSnackBar();
      },
    ),
  );
  scaffoldMessenger.showSnackBar(snackBar);
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String randomId() => String.fromCharCodes(Iterable.generate(
    randomIdLength, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String remindFormateTime(DateTime dateTime) {
  return DateFormat('MMM d, HH:mm').format(dateTime);
}
