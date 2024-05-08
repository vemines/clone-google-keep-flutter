import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keep_app/src/data/models/image_model.dart';
import 'dart:async';
import '../../routes/app_pages.dart';
import '../../shared/constants/value.dart';
import '../models/note_model.dart';
import '../models/record_model.dart';
import '../models/remind_model.dart';
import '../models/todo_model.dart';

enum Criteria {
  home,
  byLabel,
  pinnedHome,
  sentRemind,
  upcommingRemind,
  trash,
  archive,
}

class NoteService {
  late final String uid;
  late final FirebaseFirestore _firestore;

  NoteService(this.uid) {
    _firestore = FirebaseFirestore.instance;
  }

  CollectionReference getNotesCollectionRef(String uid) {
    return _firestore.collection('auths').doc(uid).collection('notes');
  }

  Future<void> deleteTrashNotes() async {
    final notesCol = getNotesCollectionRef(uid);
    final querySnapshot =
        await notesCol.where('trashed', isEqualTo: true).get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteOldTrashNotes() async {
    final notesCol = getNotesCollectionRef(uid);
    final oldTrashNotes =
        DateTime.now().subtract(Duration(days: dayAutoDeleteTrash));
    final querySnapshot =
        await notesCol.where('trashed', isEqualTo: true).get();

    for (var doc in querySnapshot.docs) {
      final deleteAt = (doc.data() as Map<String, dynamic>)['deleteAt'];
      if (deleteAt == null || deleteAt < oldTrashNotes) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> moveNoteToTrash(String noteId) async {
    await getNotesCollectionRef(uid).doc(noteId).update({
      "trashed": true,
      "deletedAt": DateTime.now,
    });
  }

  Future<void> restoreNoteInTrash(String noteId) async {
    await getNotesCollectionRef(uid).doc(noteId).update({
      "trashed": false,
      "deletedAt": null,
    });
  }

  Future<void> moveNotesToTrash(List<String> noteIds) async {
    await noteIds.map((e) => moveNoteToTrash(e));
  }

  Future<void> createNote(NoteModel note) async {
    try {
      DocumentReference noteDoc = getNotesCollectionRef(uid).doc();
      String noteId = noteDoc.id;
      note.id = noteId;
      await noteDoc.set(note.toMap());

      // Update the notesId field in the auth document
      await _firestore.collection('auths').doc(uid).update({
        'notesId': FieldValue.arrayUnion([noteDoc.id]),
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateNote(String noteId, NoteModel note) async {
    var noteCol = await getNotesCollectionRef(uid).doc(noteId);
    if ((await noteCol.get()).exists) {
      noteCol.update(note.toMap());
    }
  }

  Stream<List<NoteModel>> getNotesByCriteriaStream({
    required Criteria criteria,
    String? label,
  }) {
    StreamController<List<NoteModel>> controller =
        StreamController<List<NoteModel>>.broadcast();
    StreamSubscription<QuerySnapshot>? subscription;
    controller.onCancel = () {
      subscription?.cancel();
    };
    subscription = getNotesCollectionRef(uid).snapshots().listen(
      (querySnapshot) {
        List<NoteModel> notes = querySnapshot.docs
            .map((doc) => NoteModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        notes = queryByCriteria(criteria, notes, label);
        controller.add(notes); // Update the existing stream with new data
      },
      onError: (error) {
        print('Error in stream listener: $error');
      },
      onDone: () {
        print("done, closeStream");
        controller.close();
        subscription?.cancel();
      },
    );

    return controller.stream;
  }

  dynamic queryByCriteria(
    Criteria criteria,
    List<NoteModel> notes,
    String? labelId,
  ) {
    switch (criteria) {
      case Criteria.home:
        return notes
            .where((note) => (note.archived == false) && (note.pinned == false))
            .toList();
      case Criteria.byLabel:
        return notes
            .where((note) => ((note.labelIds ?? []).contains(labelId)))
            .toList();
      case Criteria.pinnedHome:
        return notes
            .where((note) => (note.archived == false) && (note.pinned == true))
            .toList();
      // TODO: complete sentRemind logic
      case Criteria.sentRemind:
        return notes.where((note) => note.remind != null).toList();
      // TODO: complete upcommingRemind logic
      case Criteria.upcommingRemind:
        return notes.where((note) => note.remind != null).toList();
      case Criteria.trash:
        return notes.where((note) => note.trashed == true).toList();
      case Criteria.archive:
        return notes.where((note) => note.archived == true).toList();
      default:
        return notes;
    }
  }

  Future<void> pinnedListNote(List<String> noteIds, bool value) async {
    updateListNote(noteIds, 'pinned', value);
  }

  Future<void> archiveListNote(List<String> noteIds, bool value) async {
    updateListNote(noteIds, 'archived', value);
  }

  Future<void> remindListNote(List<String> noteIds, RemindModel value) async {
    updateListNote(noteIds, 'remind', value.toMap());
  }

  Future<void> changeBgListNote(List<String> noteIds, BgColor value) async {
    updateListNote(noteIds, 'bgColor', value);
  }

  Future<void> labelsListNote(List<String> noteIds, List<String> labels) async {
    //  tagLabels
    final notesCol = getNotesCollectionRef(uid);

    for (String noteId in noteIds) {
      DocumentReference noteRef = notesCol.doc(noteId);

      DocumentSnapshot noteSnapshot = await noteRef.get();

      if (noteSnapshot.exists) {
        List<String> existingLabels = List.from(
            (noteSnapshot.data() as Map<String, dynamic>)['tagLabels'] ?? []);
        Set<String> uniqueLabels = Set.from(existingLabels)..addAll(labels);
        await noteRef.update({'labels': uniqueLabels.toList()});
      }
    }
  }

  Future<void> updateListNote(
      List<String> noteIds, String field, dynamic value) async {
    final notesCol = getNotesCollectionRef(uid);

    for (String noteId in noteIds) {
      DocumentReference noteRef = notesCol.doc(noteId);
      await noteRef.update({field: value});
    }
  }

  Future<void> deleteListNote(List<String> noteIds) async {
    final notesCol = getNotesCollectionRef(uid);

    for (String noteId in noteIds) {
      await notesCol.doc(noteId).delete();
    }

    DocumentReference authDocRef = _firestore.collection('auths').doc(uid);
    final authSnapshot = await authDocRef.get();
    List<String> notesList =
        List.from((authSnapshot.data() as Map<String, dynamic>)['notes'] ?? []);
    notesList.removeWhere((noteId) => noteIds.contains(noteId));
    await authDocRef.update({'notes': notesList});
  }

  Future<void> removeLabel(String labelId) async {
    final notesCol = getNotesCollectionRef(uid);
    var query = notesCol.where('tagLabels', arrayContains: labelId);
    print(query.count());
    query.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var tagLabels = List<String>.from(doc['tagLabels']);
        tagLabels.remove(labelId);

        notesCol.doc(doc.id).update({'tagLabels': tagLabels});
      });
    });
  }

  Future<void> sendListNote(List<String> noteIds) async {}
  Future<void> makeCopyListNote(List<String> noteIds) async {}
}

NoteModel emptyNote(
  String currentRoutes, {
  bool? isCheckBox,
  String? imageUrl,
  bool? isDrawPad,
  //record
  String? recordUrl,
  int? duration,
  // labels
  String? labelId,
  // remind
  TimeOfDay? time,
}) {
  var emptyNote = NoteModel(
    title: '',
    content: '',
  );
  switch (currentRoutes) {
    case Routes.remind:
      emptyNote.remind = RemindModel(
        date: DateTime.now().add(Duration(days: 1)).copyWith(
              hour: time?.hour ?? 8,
              minute: time?.minute ?? 0,
            ),
      );
      break;
    case Routes.label:
      if (labelId != null) {
        emptyNote.labelIds = [labelId];
      }
      break;
  }

  if (imageUrl != null) {
    emptyNote = NoteModel(
      title: '',
      content: '',
      imageUrls: [ImageModel(url: imageUrl, isDrawPad: isDrawPad ?? false)],
    );
  }
  if (isCheckBox ?? false) {
    emptyNote = NoteModel(
      title: '',
      content: '',
      todos: [TodoModel(checked: false, text: "")],
    );
  }
  if (recordUrl != null && duration != 0) {
    emptyNote = NoteModel(
      title: '',
      content: '',
      records: [RecordModel(url: recordUrl, secondsDuration: duration)],
    );
  }
  return emptyNote;
}
