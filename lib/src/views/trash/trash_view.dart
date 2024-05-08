import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/note/note_bloc.dart';
import '../../data/services/note_svc.dart';
import '../../shared/shared.dart';
import '../../data/models/note_model.dart';

class TrashView extends StatefulWidget {
  const TrashView({super.key});

  @override
  State<TrashView> createState() => _TrashViewState();
}

class _TrashViewState extends State<TrashView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isGrid = true;
  late AuthBloc authBloc;
  late String uid;
  late NoteService noteService;
  // multi select
  HashSet<NoteModel> selectItems = HashSet();
  bool isMultiSelect = false;

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    uid = (authBloc.state as AuthStateAuthenticated).uid;
    noteService = NoteService(uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrashNoteBloc(noteService),
      child: BlocBuilder<TrashNoteBloc, NoteState>(
        builder: (blocContext, state) {
          final TrashNoteBloc noteBloc = blocContext.read<TrashNoteBloc>();

          if (state is NoteStateInital) noteBloc.add(GetTrashNotesEvent());
          if (state is NoteLoadingState)
            return CenterIndicator();
          else if (state is NoteLoadErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is TrashNotesLoadedState) {
            var _notes = state.notes;

            return StreamBuilder(
              stream: _notes,
              builder: (context, snapshot) {
                return Scaffold(
                  key: scaffoldKey,
                  appBar: isMultiSelect
                      ? MultiSelectAppBar(
                          onLeading: () {
                            setState(() {
                              isMultiSelect = false;
                              selectItems.clear();
                            });
                          },
                          selected: selectItems.length,
                          onPinned: () {},
                          onArchived: () {},
                          onRemind: () {},
                          onLabels: () {},
                          onDelete: () {
                            noteService.deleteListNote(selectItems
                                .map((e) => e.id.toString())
                                .toList());
                            isMultiSelect = true;
                            selectItems.clear();
                            setState(() {});
                          },
                          onChangeNoteBg: () {},
                          onMakeCopy: () {},
                          onSend: () {},
                        ).preferredSizeAppBar()
                      : AppBarWidget(
                          title: "Trash",
                          scaffoldKey: scaffoldKey,
                          moreVert: MoreVertMenuPopup(
                            mapItems: const {
                              1: "Empty Trash",
                            },
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  noteService.deleteTrashNotes();
                                  break;
                              }
                            },
                          ),
                        ).preferredSizeAppBar(),
                  drawer: AppDrawer(),
                  body: StreamBuilder(
                    stream: _notes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          (snapshot.data ?? []).length > 0) {
                        return ListView(
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Text(
                                    "Note in Trash are deleted after ${dayAutoDeleteTrash} days",
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.close_outlined,
                                  ),
                                ),
                              ],
                            ),
                            MasonryGridView.count(
                              crossAxisCount: isGrid ? 2 : 1,
                              mainAxisSpacing: Dimensions.small,
                              crossAxisSpacing: Dimensions.small,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, innerIndex) {
                                return _noteWidget(snapshot.data![innerIndex]);
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            ),
                          ],
                        );
                      }
                      // for fix hot reload cause snapshot null data
                      if (noteBloc.state is! TrashNotesLoadedState) {
                        noteBloc.add(GetTrashNotesEvent());
                      }
                      return const EmptyNoteBodyCenter(
                        iconData: Icons.delete_outline,
                        text: "No notes in trash",
                      );
                    },
                  ),
                );
              },
            );
          } else {
            // recall if something wrong happen
            if (noteBloc.state is! TrashNotesLoadedState) {
              noteBloc.add(GetTrashNotesEvent());
            }
            return CenterIndicator();
          }
        },
      ),
    );
  }

  Widget _noteWidget(NoteModel note) => NoteWidget(
        note,
        onTap: () {
          if (isMultiSelect) {
            if (selectItems.contains(note)) {
              selectItems.remove(note);
              if (selectItems.length == 0) {
                isMultiSelect = false;
              }
            } else {
              selectItems.add(note);
            }
            setState(() {});
          } else {
            context.pushNamed(Routes.note, extra: note);
          }
        },
        onLongPress: () {
          if (!isMultiSelect) {
            isMultiSelect = true;
            selectItems.add(note);
            setState(() {});
          }
        },
        selected: selectItems.contains(note),
      );
}
