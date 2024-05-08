import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/note/note_bloc.dart';

import '../../data/models/note_model.dart';
import '../../data/services/note_svc.dart';
import '../../shared/shared.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  //inital
  late AuthBloc authBloc;
  late String uid;
  late NoteService noteService;
  // display
  bool havePinnedNote = false;
  bool isGrid = true;
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
      create: (_) => HomeNoteBloc(noteService),
      child: BlocBuilder<HomeNoteBloc, NoteState>(
        builder: (blocContext, state) {
          final HomeNoteBloc noteBloc = blocContext.read<HomeNoteBloc>();

          if (state is NoteStateInital) noteBloc.add(GetHomeNotesEvent());
          if (state is NoteLoadingState)
            return CenterIndicator();
          else if (state is NoteLoadErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is HomeNotesLoadedState) {
            var _pinnedNotes = state.notes1;
            var _homeNotes = state.notes2;

            return StreamBuilder(
              stream: _pinnedNotes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  havePinnedNote = (snapshot.data?.length ?? 0) > 0;
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
                      : null,
                  drawer: AppDrawer(),
                  body: ListView.builder(
                    itemCount: havePinnedNote ? 5 : 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return isMultiSelect
                            ? SizedBox()
                            : _HomeAppBar(scaffoldKey, isGrid, () {
                                setState(() {
                                  isGrid = !isGrid;
                                });
                              }, authBloc);
                      }
                      if (index == 1 && havePinnedNote) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(Dimensions.normal,
                              0, Dimensions.normal, Dimensions.normal),
                          child: Text("Pinned"),
                        );
                      }
                      if (index == 2 && havePinnedNote) {
                        return StreamBuilder(
                          stream: _pinnedNotes,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return MasonryGridView.count(
                                crossAxisCount: isGrid ? 2 : 1,
                                mainAxisSpacing: Dimensions.small,
                                crossAxisSpacing: Dimensions.small,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, innerIndex) {
                                  return _noteWidget(
                                      snapshot.data![innerIndex]);
                                },
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                              );
                            }
                            return CenterIndicator();
                          },
                        );
                      }
                      if (index == 3 && havePinnedNote) {
                        return Padding(
                          padding: const EdgeInsets.all(Dimensions.normal),
                          child: Text("Other"),
                        );
                      }
                      return StreamBuilder(
                        stream: _homeNotes,
                        builder: (context, snapshot) {
                          bool retry = false;
                          if (snapshot.hasData) {
                            return MasonryGridView.count(
                              crossAxisCount: isGrid ? 2 : 1,
                              mainAxisSpacing: Dimensions.small,
                              crossAxisSpacing: Dimensions.small,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, innerIndex) {
                                return _noteWidget(snapshot.data![innerIndex]);
                              },
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                            );
                          }
                          if (!snapshot.hasData && !retry) {
                            noteBloc.add(GetHomeNotesEvent());
                          }
                          // for fix hot reload cause snapshot null data
                          if (noteBloc.state is! HomeNotesLoadedState) {
                            noteBloc.add(GetHomeNotesEvent());
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
              },
            );
          } else {
            // recall if something wrong happen
            if (!(noteBloc.state is HomeNotesLoadedState)) {
              noteBloc.add(GetHomeNotesEvent());
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

class _HomeAppBar extends HookWidget {
  const _HomeAppBar(
      this.scaffoldKey, this.isGrid, this.onIsGrid, this.authBloc);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isGrid;
  final Function() onIsGrid;
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    final itemsColor = Theme.of(context).dividerColor;
    return Container(
      margin: const EdgeInsets.all(Dimensions.normal),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.small),
      decoration: BoxDecoration(
        color: ColorName.textfieldBgDark,
        borderRadius: BorderRadius.circular(RadiusBorder.homeAppBar),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => scaffoldKey.currentState!.openDrawer(),
            icon: Icon(
              Icons.menu_outlined,
              color: itemsColor,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed(Routes.search),
              child: Text(
                "Search your notes",
                style: TextStyle(
                  color: itemsColor,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onIsGrid,
            icon: Icon(
              isGrid
                  ? Icons.splitscreen_outlined
                  : Icons.format_list_bulleted_outlined,
              color: itemsColor,
            ),
          ),
          gapS(),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AccountDialog(
                  onLogout: () {
                    authBloc.add(SignOutEvent());
                    context.pop();
                  },
                  onAddAccount: () {},
                  onEditProfile: () {},
                  onManagerAccount: () {},
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 20,
              child: Assets.png.avatar.image(fit: BoxFit.fill),
            ),
          ),
          gapN(),
        ],
      ),
    );
  }
}
