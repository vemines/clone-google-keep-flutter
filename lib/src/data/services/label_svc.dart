import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/label_model.dart';

class LabelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _getLabelsCollection(String uid) =>
      _firestore.collection('auths').doc(uid).collection('labels');
  LabelService._() {}
  static LabelService instance = LabelService._();

  Future<void> updateLabels(String uid, List<LabelModel> labels) async {
    final labelsCollection = _getLabelsCollection(uid);
    for (var label in labels) {
      if (label.id == null) {
        var docRef = await labelsCollection.add(label.toMap());
        await docRef.update({'id': docRef.id});
      } else {
        await updateLabel(uid, label);
      }
    }
  }

  Future<List<LabelModel>> getCurrentLabels(String uid) async {
    var labelsCollection = _getLabelsCollection(uid);
    var snapshot = await labelsCollection.get();
    return snapshot.docs.map((doc) => LabelModel.fromMap(doc.data())).toList();
  }

  Stream<List<LabelModel>> labelsStream(String uid) {
    var labelsCollection = _getLabelsCollection(uid);
    return labelsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LabelModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> updateLabel(String uid, LabelModel label) async {
    var labelsCollection = _getLabelsCollection(uid);
    await labelsCollection.doc(label.id).set(label.toMap());
  }

  Future<void> deleteLabel(String uid, String labelId) async {
    if (labelId != "") {
      var labelsCollection = _getLabelsCollection(uid);
      await labelsCollection.doc(labelId).delete();
    }
  }

  Future<String> getLabelById(String uid, String labelId) async {
    var labelsCollection = _getLabelsCollection(uid);
    var doc = await labelsCollection.doc(labelId).get();
    if (doc.exists) {
      return doc.data()!['label'];
    } else {
      throw Exception('Label not found');
    }
  }
}
