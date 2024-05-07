import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

final _pathDataFile = getApplicationDocumentsDirectory();

Future<Uint8List> readFileAsUint8List(String fileName) async {
  File file = File("$_pathDataFile/$fileName");
  if (await file.exists()) {
    return await file.readAsBytes();
  } else {
    throw FileSystemException('File not found');
  }
}
