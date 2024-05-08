import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/image_model.dart';
import '../../data/models/label_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/setting_model.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/label_svc.dart';
import '../../data/services/note_svc.dart';
import '../../data/services/auth_svc.dart';
import '../../shared/shared.dart';
import 'note_provider.dart';

part 'widgets/todo.dart';
part 'widgets/audio_player.dart';
part 'widgets/bottom_nav.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    String uid = (authBloc.state as AuthStateAuthenticated).uid;
    NoteService noteService = NoteService(uid);
    AuthService authService = AuthService.instance;
    NoteModel? extra = GoRouterState.of(context).extra as NoteModel?;

    return FutureBuilder<AuthModel?>(
        future: authService.getUser(uid),
        builder: (context, snapshot) {
          late SettingsModel? settingsModel;
          if (snapshot.hasData) {
            settingsModel = snapshot.data?.settings;
          }
          return ChangeNotifierProvider(
            create: (_) => NoteProvider(noteService, extra, uid),
            builder: (providerContext, child) {
              return SafeArea(
                child: Consumer<NoteProvider>(
                  builder: (appBarContext, provider, child) {
                    if (extra != null) provider.setCurrentNote(extra);
                    return Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back_outlined),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => provider.pinnedNote(),
                            icon: Icon(provider.currentNote.pinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined),
                          ),
                          IconButton(
                            onPressed: () => settingsModel != null
                                ? provider.addRemind(context, settingsModel)
                                : {},
                            icon: Icon(
                              provider.currentNote.remind != null
                                  ? Icons.notification_add
                                  : Icons.notification_add_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () => provider.archiveNote(),
                            icon: Icon(provider.currentNote.archived
                                ? Icons.archive
                                : Icons.archive_outlined),
                          ),
                        ],
                      ),
                      body: _EditNoteBody(
                        provider: provider,
                        noteModel: provider.currentNote,
                        uid: uid,
                      ),
                      bottomNavigationBar: _NoteBottom(
                        provider,
                        onChangeBgColor: provider.setBgNoteColor,
                        onChangeBgImage: provider.setBgNoteImage,
                      ),
                    );
                  },
                ),
              );
            },
          );
        });
  }
}

class _EditNoteBody extends StatefulWidget {
  final NoteModel noteModel;
  final NoteProvider provider;
  final String uid;
  const _EditNoteBody({
    required this.noteModel,
    required this.provider,
    required this.uid,
  });

  @override
  State<_EditNoteBody> createState() => _EditNoteBodyState();
}

class _EditNoteBodyState extends State<_EditNoteBody> {
  late TextEditingController titleTextContr;
  late TextEditingController contentTextContr;
  LabelService labelService = LabelService.instance;
  @override
  void initState() {
    super.initState();
    titleTextContr = TextEditingController(text: widget.noteModel.title);
    contentTextContr = TextEditingController(text: widget.noteModel.content);
  }

  @override
  void dispose() {
    super.dispose();
    titleTextContr.dispose();
    contentTextContr.dispose();
    widget.provider.saveNote();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final hintColor = context.theme.hintColor;
    NoteModel note = widget.noteModel;
    List<ImageModel> imageList = widget.provider.currentNote.imageUrls ?? [];

    return Container(
      decoration: BoxDecoration(
        image: note.bgNote != 0
            ? DecorationImage(
                image: Image.asset(intToBgNoteImage(note.bgNote)!).image,
                fit: BoxFit.cover,
              )
            : null,
        color: note.bgColor != 0 ? intToBgNoteColor(note.bgColor) : null,
      ),
      child: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageList.isNotEmpty) _StaggeredGridSection(imageList),
                  TextField(
                    controller: titleTextContr,
                    decoration: InputDecoration(
                      suffix: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                      hintText: "Title",
                      contentPadding: EdgeInsets.only(left: Dimensions.normal),
                      hintStyle: textTheme.titleLarge!.copyWith(
                        color: context.theme.hintColor,
                      ),
                      border: InputBorder.none,
                    ),
                    style: textTheme.titleLarge,
                    onChanged: (value) => widget.provider.setTitle(value),
                  ),
                  TextField(
                    controller: contentTextContr,
                    decoration: const InputDecoration(
                      hintText: "Note",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: Dimensions.normal),
                    ),
                    maxLines: null,
                    onChanged: (value) => widget.provider.setContent(value),
                  ),
                  if ((note.todos?.length ?? 0) > 0)
                    _TodoSection(note.todos!, widget.provider),
                  if ((note.records?.length ?? 0) > 0)
                    for (int i = 0; i < note.records!.length; i++)
                      ListTile(
                        title: _AudioPlayer(note.records![i].url!),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.normal,
                        ),
                        horizontalTitleGap: 0,
                        tileColor: ColorName.textfieldBgDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              RadiusBorder.recordListTitle),
                        ),
                        trailing: Padding(
                          padding:
                              const EdgeInsets.only(left: Dimensions.normal),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                  if (note.remind != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.normal),
                      child: GreyFilledButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.alarm_outlined,
                              color: note.remind!.date!.isAfter(DateTime.now())
                                  ? Colors.white
                                  : hintColor,
                            ),
                            gapN(),
                            Text(
                              remindFormateTime(note.remind!.date!),
                              style: note.remind!.date!.isAfter(DateTime.now())
                                  ? textTheme.labelLarge
                                  : textTheme.labelLarge!.copyWith(
                                      color: hintColor,
                                      decoration: TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: hintColor,
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  if ((note.labelIds?.length ?? 0) > 0)
                    Wrap(
                      spacing: Dimensions.small,
                      runSpacing: Dimensions.small,
                      children: note.labelIds!
                          .map(
                            (labelId) => GreyFilledButton(
                              child: FutureBuilder<String>(
                                  future: labelService.getLabelById(
                                      widget.uid, labelId),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? "",
                                      style: context.textTheme.labelLarge,
                                    );
                                  }),
                              onPressed: () {},
                            ),
                          )
                          .toList()
                          .separateCenter(),
                    ),
                  gapN(),
                  if (note.bgNote != 0 && note.bgColor != 0)
                    Container(
                      margin: EdgeInsets.all(Dimensions.normal),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: intToBgNoteColor(note.bgColor),
                      ),
                      width: 36,
                      height: 36,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredGridSection extends StatelessWidget {
  const _StaggeredGridSection(this.urls);
  final List<ImageModel> urls;

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 6,
      crossAxisSpacing: Dimensions.small,
      mainAxisSpacing: Dimensions.small,
      children: generateStaggeredGridTiles(urls),
    );
  }
}
