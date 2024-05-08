import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_app/src/data/models/label_model.dart';
import 'package:keep_app/src/data/services/note_svc.dart';
import '../../data/models/image_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/record_model.dart';
import '../../data/models/remind_model.dart';
import '../../data/models/setting_model.dart';
import '../../data/models/todo_model.dart';
import '../../routes/app_pages.dart';
import '../../shared/helpers/firebase_storage_helper.dart';
import '../../shared/extensions/context_ext.dart';
import '../../shared/utils/util.dart';

class NoteProvider with ChangeNotifier {
  final NoteService noteService;
  final NoteModel? extra;
  final String uid;
  NoteModel _currentNote = NoteModel(
    title: "",
    content: "",
  );

  NoteProvider(this.noteService, this.extra, this.uid) {
    if (extra != null) {
      _currentNote = extra!;
    }
  }

  FirebaseStorageHelper storageHelper = FirebaseStorageHelper();

  NoteModel get currentNote => _currentNote;

  Future<void> saveNote() async {
    if (!_currentNote.isEmptyNote()) {
      if (_currentNote.id != null) {
        noteService.updateNote(_currentNote.id!, _currentNote);
      } else {
        noteService.createNote(_currentNote);
      }
    }
  }

  Future<void> clear() async {
    String? id = _currentNote.id;
    delete();
    _currentNote.id = id;
    notifyListeners();
  }

  void setBgNoteColor(int color) {
    _currentNote.bgColor = color;
    notifyListeners();
  }

  void setBgNoteImage(int image) {
    _currentNote.bgNote = image;
    notifyListeners();
  }

  Future<void> delete() async {
    if (_currentNote.id != null) {
      noteService.moveNoteToTrash(_currentNote.id!);
    }
    _currentNote = NoteModel(title: "", content: "");
  }

  Future<void> labels(List<LabelModel>? selected) async {
    _currentNote.labelIds = (selected ?? []).map((e) => e.id!).toList();
  }

  void setTitle(String title) {
    _currentNote.title = title;
  }

  void setContent(String content) {
    _currentNote.content = content;
  }

  void setCurrentNote(NoteModel note) {
    _currentNote = note;
  }

  void setTodos(List<TodoModel> todos) {
    _currentNote.todos = todos;
  }

  List<String> handleAddToList({
    required List<String>? list,
    required String path,
  }) {
    List<String> updatedList = list ?? [];
    if (path.isNotEmpty) {
      updatedList.add(path);
    }
    return updatedList;
  }

  Future<void> addTodo() async {
    if (_currentNote.todos == null) {
      _currentNote.todos = [
        TodoModel(text: "", checked: false),
      ];
    } else {
      _currentNote.todos!.add(
        TodoModel(text: "", checked: false),
      );
    }
    notifyListeners();
  }

  Future<void> addPhoto() async {
    XFile? imageFile = await pickImage();

    if (imageFile != null) {
      final cacheDir = await cacheDirectory();
      String fileName = fileNameByTimestamp("image", "png");
      final savedImagePath = '$cacheDir/$fileName';
      await imageFile.saveTo(savedImagePath);

      await storageHelper.uploadFileToStorage(
          savedImagePath, "$uid/image/$fileName");

      _currentNote.imageUrls = (_currentNote.imageUrls ?? [])
        ..add(ImageModel(isDrawPad: false, url: savedImagePath));

      notifyListeners();
    }
  }

  Future<void> addTakePhoto() async {
    final XFile? imageFile = await takePhoto();
    if (imageFile != null) {
      final cacheDir = await cacheDirectory();
      String fileName = fileNameByTimestamp("image", "png");
      final savedImagePath = '$cacheDir/$fileName';
      await imageFile.saveTo(savedImagePath);

      await storageHelper.uploadFileToStorage(
          savedImagePath, "$uid/image/$fileName");

      _currentNote.imageUrls = (_currentNote.imageUrls ?? [])
        ..add(ImageModel(isDrawPad: false, url: savedImagePath));
      notifyListeners();
    }
  }

  Future<void> addDrawPad(BuildContext context) async {
    await context.pushNamed(Routes.drawPad).then((result) async {
      if (result is Uint8List && result.isNotEmpty) {
        final randId = randomId();
        final savedDrawPadPath =
            await saveUint8ListToCache(result, "drawPad_$randId");
        await storageHelper.uploadUint8List(result, '$uid/drawPad_$randId');
        _currentNote.imageUrls = (_currentNote.imageUrls ?? [])
          ..add(ImageModel(isDrawPad: true, url: savedDrawPadPath));
      }
    });
    notifyListeners();
  }

  Future<void> addRecording(BuildContext context) async {
    final cacheDir = await cacheDirectory();
    String fileName = fileNameByTimestamp("record", "aac");
    final savedRecordingPath = '$cacheDir/$fileName';

    await record(savedRecordingPath, context, (duration) async {
      if (duration != null) {
        _currentNote.records = _currentNote.records ?? [];
        _currentNote.records!.add(RecordModel(
          url: savedRecordingPath,
          secondsDuration: duration.inSeconds,
        ));
      }

      await storageHelper.uploadFileToStorage(
        savedRecordingPath,
        "$uid/record/$fileName",
      );
    });
  }

  void changeBgNote(int bgNote) {
    _currentNote.bgNote = bgNote;
    notifyListeners();
  }

  void changeBgColor(int bgColor) {
    _currentNote.bgColor = bgColor;
    notifyListeners();
  }

  Future<void> pinnedNote() async {
    _currentNote.pinned = !_currentNote.pinned;
    notifyListeners();
  }

  Future<void> archiveNote() async {
    _currentNote.archived = !_currentNote.archived;
    _currentNote.pinned = false;
    notifyListeners();
  }

  void addRemind(
    BuildContext context,
    SettingsModel settingsModel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final textStyle = context.textTheme.bodyMedium;
        final unselectColor = context.theme.unselectedWidgetColor;
        return Column(
          children: [
            ListTile(
              title: Text("Tomorrow morning"),
              trailing: Text(
                settingsModel.morningRemind,
                style: textStyle,
              ),
              leading: Icon(Icons.access_time_outlined),
              onTap: () async {
                final time = stringToTimeOfDay(settingsModel.morningRemind);
                final hour = time.hour;
                final minute = time.minute;
                _currentNote.remind = RemindModel(
                  date: DateTime.now().add(Duration(days: 1)).copyWith(
                        hour: hour,
                        minute: minute,
                        second: 0,
                      ),
                );
                notifyListeners();
                context.pop();
              },
            ),
            ListTile(
              title: Text("Tomorrow afternoon"),
              trailing: Text(
                settingsModel.afternoonRemind,
                style: textStyle,
              ),
              leading: Icon(Icons.access_time_outlined),
              onTap: () {
                final time = stringToTimeOfDay(settingsModel.afternoonRemind);
                final hour = time.hour;
                final minute = time.minute;
                _currentNote.remind = RemindModel(
                  date: DateTime.now().add(Duration(days: 1)).copyWith(
                        hour: hour,
                        minute: minute,
                        second: 0,
                      ),
                );
                notifyListeners();
                context.pop();
              },
            ),
            ListTile(
              title: Text("Tomorrow evening"),
              trailing: Text(
                settingsModel.eveningRemind,
                style: textStyle,
              ),
              leading: Icon(Icons.access_time_outlined),
              onTap: () {
                final time = stringToTimeOfDay(settingsModel.eveningRemind);
                final hour = time.hour;
                final minute = time.minute;
                _currentNote.remind = RemindModel(
                  date: DateTime.now().add(Duration(days: 1)).copyWith(
                        hour: hour,
                        minute: minute,
                        second: 0,
                      ),
                );
                notifyListeners();
                context.pop();
              },
            ),
            ListTile(
              title: Text("Home", style: TextStyle(color: unselectColor)),
              leading: Icon(Icons.home, color: unselectColor),
              onTap: null,
            ),
            ListTile(
              title: Text("Work", style: TextStyle(color: unselectColor)),
              leading: Icon(Icons.work, color: unselectColor),
              onTap: null,
            ),
            ListTile(
              title: Text("Pick a date & time"),
              leading: Icon(Icons.access_time_outlined),
              onTap: () {
                // _currentNote.remind = RemindModel();
                context.pop();
              },
            ),
            ListTile(
              title: Text("Pick a place"),
              leading: Icon(Icons.place_outlined),
              onTap: () {
                //  _currentNote.remind = RemindModel();
                context.pop();
              },
            ),
          ],
        );
      },
    );
    notifyListeners();
  }

  Future<void> makeCopy() async {}
  Future<void> send() async {}
  Future<void> collaborator() async {}
}
