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

class ArchiveView extends StatefulWidget {
  const ArchiveView({super.key});

  @override
  State<ArchiveView> createState() => _ArchiveViewState();
}

class _ArchiveViewState extends State<ArchiveView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
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
      create: (_) => ArchiveNoteBloc(noteService),
      child: BlocBuilder<ArchiveNoteBloc, NoteState>(
        builder: (blocContext, state) {
          final ArchiveNoteBloc noteBloc = blocContext.read<ArchiveNoteBloc>();

          if (state is NoteStateInital) noteBloc.add(GetArchivedNotesEvent());
          if (state is NoteLoadingState)
            return CenterIndicator();
          else if (state is NoteLoadErrorState) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is ArchiveNotesLoadedState) {
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
                          onDelete: () {},
                          onChangeNoteBg: () {},
                          onMakeCopy: () {},
                          onSend: () {},
                        ).preferredSizeAppBar()
                      : AppBarWidget(
                          title: "Archive",
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
                      if (noteBloc.state is! ArchiveNotesLoadedState) {
                        noteBloc.add(GetArchivedNotesEvent());
                      }
                      return const EmptyNoteBodyCenter(
                        iconData: Icons.archive_outlined,
                        text: "Your archive notes appear here",
                      );
                    },
                  ),
                );
              },
            );
          } else {
            // recall if something wrong happen
            if (noteBloc.state is! ArchiveNotesLoadedState) {
              noteBloc.add(GetArchivedNotesEvent());
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
