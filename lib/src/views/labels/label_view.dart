import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/note/note_bloc.dart';
import '../../data/models/label_model.dart';
import '../../data/services/label_svc.dart';
import '../../data/services/note_svc.dart';
import '../../shared/shared.dart';
import '../../data/models/note_model.dart';

class LabelView extends StatefulWidget {
  const LabelView(this.label, {super.key});
  final LabelModel label;

  @override
  State<LabelView> createState() => _LabelViewState();
}

class _LabelViewState extends State<LabelView> {
  late String _label;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isGrid = true;
  late NoteBloc noteBloc;
  late AuthBloc authBloc;
  late String uid;
  late NoteService noteService;
  late LabelService labelService;
  // multi select
  HashSet<NoteModel> selectItems = HashSet();
  bool isMultiSelect = false;

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    uid = (authBloc.state as AuthStateAuthenticated).uid;
    noteService = NoteService(uid);
    labelService = LabelService.instance;
    _label = widget.label.label;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabelNoteBloc(noteService),
      child: BlocBuilder<LabelNoteBloc, NoteState>(
        builder: (blocContext, state) {
          final LabelNoteBloc noteBloc = blocContext.read<LabelNoteBloc>();
          if (state is NoteStateInital)
            noteBloc.add(GetNoteByLabelEvent(widget.label.id ?? ""));
          if (state is NoteLoadingState)
            return CenterIndicator();
          else if (state is NoteLoadErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is LabelNotesLoadedState) {
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
                          title: _label,
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
                          moreVert: MoreVertMenuPopup(
                            mapItems: const {
                              1: "Rename Label",
                              2: "Delete Label",
                            },
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  showSingleTextFieldDialog(
                                    context,
                                    "Rename Label",
                                    confirmText: "Rename",
                                    initText: widget.label.label,
                                    onConfirm: (l) {
                                      var updateLabel = widget.label..label = l;
                                      labelService.updateLabel(
                                        uid,
                                        updateLabel,
                                      );

                                      setState(() {
                                        _label = l;
                                      });
                                    },
                                  );
                                  break;
                                case 2:
                                  labelService.deleteLabel(
                                      uid, widget.label.id ?? "");
                                  noteService.removeLabel(widget.label.id!);
                                  context.pushNamed(Routes.home);
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
                        return MasonryGridView.count(
                          crossAxisCount: isGrid ? 2 : 1,
                          mainAxisSpacing: Dimensions.small,
                          crossAxisSpacing: Dimensions.small,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, innerIndex) {
                            return _noteWidget(snapshot.data![innerIndex]);
                          },
                        );
                      }
                      // for fix hot reload cause snapshot null data
                      if (noteBloc.state is! LabelNotesLoadedState) {
                        noteBloc
                            .add(GetNoteByLabelEvent(widget.label.id ?? ""));
                      }
                      return const EmptyNoteBodyCenter(
                        iconData: Icons.label_outline,
                        text: "No notes with this label yet",
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
                  bottomNavigationBar: NoteBottomNav(
                    noteService,
                    uid,
                    label: widget.label,
                  ),
                );
              },
            );
          } else {
            if (noteBloc.state is! LabelNotesLoadedState) {
              noteBloc.add(GetNoteByLabelEvent(widget.label.id ?? ""));
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
