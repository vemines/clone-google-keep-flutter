import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/label_model.dart';
import '../../data/services/note_svc.dart';
import '../helpers/firebase_storage_helper.dart';
import '../shared.dart';

class NoteBottomNav extends StatelessWidget {
  const NoteBottomNav(
    this.noteService,
    this.uid, {
    super.key,
    this.label,
  });
  final NoteService noteService;
  final String uid;
  final LabelModel? label;
  @override
  Widget build(BuildContext context) {
    FirebaseStorageHelper storageHelper = FirebaseStorageHelper();
    String route =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    return Container(
      color: ColorName.textfieldBgDark,
      padding: const EdgeInsets.only(left: Dimensions.normal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBox(
            onTap: () async {
              context.pushNamed(
                Routes.note,
                extra: emptyNote(
                  route,
                  isCheckBox: true,
                  labelId: label?.id,
                ),
              );
            },
            iconData: Icons.check_box_outlined,
          ),
          iconBox(
            onTap: () async {
              String savedDrawPadPath = "";
              await context.pushNamed(Routes.drawPad).then((result) async {
                if (result is Uint8List && result.isNotEmpty) {
                  savedDrawPadPath = await saveUint8ListToCache(
                      result, "drawPad_${randomId()}");
                  await storageHelper.uploadUint8List(
                      result, '$uid/drawPad_${randomId()}');
                }
              });
              if (savedDrawPadPath.isNotEmpty) {
                context.pushNamed(
                  Routes.note,
                  extra: emptyNote(
                    route,
                    isDrawPad: true,
                    imageUrl: savedDrawPadPath,
                    labelId: label?.id,
                  ),
                );
              }
            },
            iconData: Icons.edit_outlined,
          ),
          iconBox(
            onTap: () async {
              final cacheDir = await cacheDirectory();
              String fileName = fileNameByTimestamp("record", "aac");
              final savedRecordingPath = '$cacheDir/$fileName';

              await record(savedRecordingPath, context, (duration) {
                if (duration != null) {
                  context.pushNamed(
                    Routes.note,
                    extra: emptyNote(
                      route,
                      recordUrl: savedRecordingPath,
                      duration: duration.inSeconds,
                      labelId: label?.id,
                    ),
                  );
                }
              });
            },
            iconData: Icons.keyboard_voice_outlined,
          ),
          iconBox(
            onTap: () async {
              final XFile? imageFile = await takePhoto();
              if (imageFile != null) {
                final cacheDir = await cacheDirectory();
                String fileName = fileNameByTimestamp("image", "png");
                final savedImagePath = '$cacheDir/$fileName';
                await imageFile.saveTo(savedImagePath);

                await storageHelper.uploadFileToStorage(
                    savedImagePath, "$uid/image/$fileName");

                context.pushNamed(
                  Routes.note,
                  extra: emptyNote(
                    route,
                    imageUrl: savedImagePath,
                    labelId: label?.id,
                  ),
                );
              }
            },
            iconData: Icons.image_outlined,
          ),
        ].separateCenter(Dimensions.small),
      ),
    );
  }
}
