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

class RemindView extends StatefulWidget {
  const RemindView({super.key});

  @override
  State<RemindView> createState() => _RemindViewState();
}

class _RemindViewState extends State<RemindView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool haveSentNote = false;
  bool haveUpcommingNote = false;
  bool isGrid = true;
  late AuthBloc authBloc;
  late String uid;
  late NoteService noteService; // multi select
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
      create: (_) => RemindNoteBloc(noteService),
      child: BlocBuilder<RemindNoteBloc, NoteState>(
        builder: (blocContext, state) {
          final RemindNoteBloc noteBloc = blocContext.read<RemindNoteBloc>();

          if (state is NoteStateInital) noteBloc.add(GetRemindNotesEvent());
          if (state is NoteLoadingState)
            return CenterIndicator();
          else if (state is NoteLoadErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is RemindNotesLoadedState) {
            var _sentNotes = state.notes1;
            var _upcommingNotes = state.notes2;

            return StreamBuilder(
              stream: _sentNotes,
              builder: (context, sentNoteSnapshot) {
                if (sentNoteSnapshot.hasData) {
                  haveSentNote = (sentNoteSnapshot.data?.length ?? 0) > 0;
                }

                return StreamBuilder(
                    stream: _upcommingNotes,
                    builder: (context, upcomingNoteSnapshot) {
                      if (upcomingNoteSnapshot.hasData) {
                        haveUpcommingNote =
                            (upcomingNoteSnapshot.data?.length ?? 0) > 0;
                      }

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
                                title: "Remind",
                                scaffoldKey: scaffoldKey,
                                showSearch: true,
                                showGrid: true,
                                gridValue: isGrid,
                                onSearch: () {
                                  context.pushNamed(Routes.search);
                                },
                                onGrid: () {
                                  setState(() {
                                    isGrid = !isGrid;
                                  });
                                },
                              ).preferredSizeAppBar(),
                        drawer: AppDrawer(),
                        body: (!haveSentNote && !haveUpcommingNote)
                            ? EmptyNoteBodyCenter(
                                iconData: Icons.notifications_outlined,
                                text: "Notes with upcoming reminds appear here",
                              )
                            : ListView.builder(
                                itemCount: haveSentNote ? 4 : 1,
                                itemBuilder: (context, index) {
                                  if (index == 0 && haveSentNote) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          Dimensions.normal,
                                          0,
                                          Dimensions.normal,
                                          Dimensions.normal),
                                      child: Text("Sent"),
                                    );
                                  }
                                  if (index == 1 && haveSentNote) {
                                    return StreamBuilder(
                                      stream: _sentNotes,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return MasonryGridView.count(
                                            crossAxisCount: isGrid ? 2 : 1,
                                            mainAxisSpacing: Dimensions.small,
                                            crossAxisSpacing: Dimensions.small,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, innerIndex) {
                                              return _noteWidget(
                                                snapshot.data![innerIndex],
                                              );
                                            },
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                          );
                                        }
                                        return CenterIndicator();
                                      },
                                    );
                                  }
                                  if (index == 2 && haveSentNote) {
                                    return Padding(
                                      padding: const EdgeInsets.all(
                                          Dimensions.normal),
                                      child: Text("Upcomming"),
                                    );
                                  }
                                  return StreamBuilder(
                                    stream: _upcommingNotes,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          (snapshot.data ?? []).length > 0) {
                                        return MasonryGridView.count(
                                          crossAxisCount: isGrid ? 2 : 1,
                                          mainAxisSpacing: Dimensions.small,
                                          crossAxisSpacing: Dimensions.small,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, innerIndex) {
                                            return _noteWidget(
                                              snapshot.data![innerIndex],
                                            );
                                          },
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                        );
                                      }
                                      // for fix hot reload cause snapshot null data
                                      if (noteBloc.state
                                          is! RemindNotesLoadedState) {
                                        noteBloc.add(GetRemindNotesEvent());
                                      }
                                      return CenterIndicator();
                                    },
                                  );
                                },
                              ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.endDocked,
                        floatingActionButton: Padding(
                          padding: const EdgeInsets.only(
                            right: Dimensions.normal,
                            bottom: Dimensions.small,
                          ),
                          child: FloatingActionButton(
                            onPressed: () {
                              context.pushNamed(
                                Routes.note,
                                // extra: {EmptyNoteType.normal: ""}
                              );
                            },
                            backgroundColor: ColorName.textfieldBgDark,
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.small),
                              child: Assets.png.add.image(),
                            ),
                          ),
                        ),
                        bottomNavigationBar: NoteBottomNav(noteService, uid),
                      );
                    });
              },
            );
          } else {
            // recall if something wrong happen
            if (noteBloc.state is! RemindNotesLoadedState) {
              noteBloc.add(GetRemindNotesEvent());
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
