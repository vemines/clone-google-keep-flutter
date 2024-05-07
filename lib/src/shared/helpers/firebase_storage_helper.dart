import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadUint8List(Uint8List input, String saveTo) async {
    final ref = _storage.ref().child(saveTo);
    final uploadTask = ref.putData(input);

    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<Uint8List?> download(String url) async {
    final ref = _storage.refFromURL(url);
    final downloadData = await ref.getData();
    return downloadData;
  }

  Future<void> delete(String url) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    await ref.delete();
  }

  Future<void> uploadFileToStorage(String filePath, String name) async {
    Reference ref = _storage.ref().child('$name');
    final File uploadFile = File(filePath);
    UploadTask uploadTask = ref.putFile(uploadFile);
    await uploadTask
        .whenComplete(() => print('Image uploaded to Firebase Storage'));
  }
}
