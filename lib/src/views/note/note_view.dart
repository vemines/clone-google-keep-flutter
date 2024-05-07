import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                      bottomNavigationBar: _NoteBottom(provider),
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
    NoteModel noteModel = widget.noteModel;
    List<ImageModel> imageList = widget.provider.currentNote.imageUrls ?? [];

    return SingleChildScrollView(
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
          if ((noteModel.todos?.length ?? 0) > 0)
            _TodoSection(noteModel.todos!, widget.provider),
          if ((noteModel.records?.length ?? 0) > 0)
            for (int i = 0; i < noteModel.records!.length; i++)
              ListTile(
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline),
                ),
                title: Row(
                  children: [
                    Expanded(child: Slider(value: 0, onChanged: (value) {})),
                    Text(
                      formatDuration(noteModel.records![i].secondsDuration),
                      style: context.textTheme.labelMedium!.copyWith(
                        color: hintColor,
                      ),
                    )
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.normal,
                ),
                horizontalTitleGap: 0,
                tileColor: ColorName.textfieldBgDark,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(RadiusBorder.recordListTitle),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(left: Dimensions.normal),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
          if (noteModel.remind != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.normal),
              child: GreyFilledButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alarm_outlined,
                      color: hintColor,
                    ),
                    gapN(),
                    Text(
                      remindFormateTime(noteModel.remind!.date!),
                      style: textTheme.labelLarge!.copyWith(
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
          if ((noteModel.labelIds?.length ?? 0) > 0)
            ...noteModel.labelIds!
                .map(
                  (labelId) => GreyFilledButton(
                    child: FutureBuilder<String>(
                        future: labelService.getLabelById(widget.uid, labelId),
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
          gapN(),
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

class _TodoSection extends StatefulWidget {
  const _TodoSection(this.todos, this.provider);
  final List<TodoModel> todos;
  final NoteProvider provider;

  @override
  State<_TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<_TodoSection> {
  late List<TodoModel> checkedTodo;
  late List<TodoModel> uncheckedTodo;
  @override
  void initState() {
    super.initState();
    checkedTodo = widget.todos.where((todo) => todo.checked == true).toList();
    uncheckedTodo =
        widget.todos.where((todo) => todo.checked == false).toList();
  }

  void addTodo() {
    uncheckedTodo.add(TodoModel(checked: false, text: ""));
    setState(() {});
  }

  void addCheckedTodo(TodoModel todo) {
    uncheckedTodo.remove(todo);
    todo.checked = true;
    checkedTodo.add(todo);
    setState(() {});
  }

  void removeCheckedTodo(TodoModel todo) {
    checkedTodo.remove(todo);
    todo.checked = false;
    uncheckedTodo.add(todo);
    setState(() {});
  }

  void removeTodo(bool isCheck, TodoModel todo) {
    isCheck ? checkedTodo.remove(todo) : uncheckedTodo.remove(todo);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.setTodos([...uncheckedTodo, ...checkedTodo]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            for (int i = 0; i < uncheckedTodo.length; i++)
              _TodoItem(
                key: UniqueKey(),
                todo: uncheckedTodo[i],
                index: i,
                onChecked: () => addCheckedTodo(uncheckedTodo[i]),
                onUnchecked: () => removeCheckedTodo(uncheckedTodo[i]),
                onRemove: () => removeTodo(false, uncheckedTodo[i]),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = uncheckedTodo.removeAt(oldIndex);
              uncheckedTodo.insert(newIndex, item);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: Dimensions.normal * 2),
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text("List item", style: context.textTheme.bodyLarge),
            onTap: addTodo,
          ),
        ),
        if (checkedTodo.length > 0)
          ExpansionTile(
            initiallyExpanded: true,
            shape: Border.all(width: 0),
            title: Text(
              "${checkedTodo.length} Checked items",
              style: context.textTheme.titleMedium,
            ),
            children: checkedTodo
                .map(
                  (todo) => _TodoItem(
                    key: UniqueKey(),
                    todo: todo,
                    index: null,
                    onChecked: () => addCheckedTodo(todo),
                    onUnchecked: () => removeCheckedTodo(todo),
                    onRemove: () => removeTodo(true, todo),
                  ),
                )
                .toList(),
          )
      ],
    );
  }
}

class _TodoItem extends StatefulWidget {
  const _TodoItem({
    required Key key,
    required this.todo,
    required this.onChecked,
    required this.onUnchecked,
    required this.onRemove,
    this.index,
  }) : super(key: key);
  final TodoModel todo;
  final Function() onChecked;
  final Function() onUnchecked;
  final Function() onRemove;
  final int? index;

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> {
  bool _isFocus = false;
  final FocusNode focusNode = FocusNode();
  late TextEditingController textEditController;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
    textEditController = TextEditingController(text: widget.todo.text);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    textEditController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: widget.todo.checked ? 0 : 1,
          child: widget.index == null
              ? Icon(Icons.drag_indicator_outlined)
              : ReorderableDragStartListener(
                  index: widget.index!,
                  child: const Icon(Icons.drag_indicator_outlined),
                ),
        ),
        Flexible(
          child: CheckboxListTile(
            value: widget.todo.checked,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: context.theme.hintColor,
            onChanged: (value) {
              if (value != null) {
                value ? widget.onChecked() : widget.onUnchecked();
              }
            },
            title: TextField(
              focusNode: focusNode,
              controller: textEditController,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: _isFocus
                    ? IconButton(
                        onPressed: widget.onRemove,
                        icon: Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: (value) {
                widget.todo.text = value;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteBottom extends StatelessWidget {
  const _NoteBottom(this.provider);
  final NoteProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MoreVertMenuPopup(
          mapItems: const {
            0: "Take Photo",
            1: "Add image",
            2: "Drawing",
            3: "Recording",
            4: "Checkboxes",
          },
          onSelected: (value) {
            switch (value) {
              case 0:
                provider.addTakePhoto();
                break;
              case 1:
                provider.addPhoto();
                break;
              case 2:
                provider.addDrawPad(context);
                break;
              case 3:
                provider.addRecording(context);
                break;
              case 4:
                provider.addTodo();
                break;
            }
          },
          iconData: Icons.add_box_outlined,
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                final onSurface = context.colorScheme.onSurface;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.large,
                        left: Dimensions.normal,
                      ),
                      child: Text(
                        "Select background color",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.only(left: Dimensions.normal),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: onSurface),
                              ),
                              child: Icon(
                                Icons.format_color_reset_outlined,
                                color: onSurface,
                              ),
                            ),
                            ...Colors.primaries.map((e) => CircleAvatar(
                                  backgroundColor: e,
                                  minRadius: 25,
                                )),
                          ].separateCenter(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.normal,
                        left: Dimensions.normal,
                      ),
                      child: Text(
                        "Select background image",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: onSurface),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: onSurface,
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Assets.jpg.bg1.image(fit: BoxFit.fill),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Assets.jpg.bg2.image(fit: BoxFit.fill),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Assets.jpg.bg3.image(fit: BoxFit.fill),
                          ),
                        ].separateAll(),
                      ),
                    ),
                    gapS(),
                  ].separateCenter(),
                );
              },
            );
          },
          icon: const Icon(Icons.palette_outlined),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.text_format_outlined),
        ),
        const Expanded(
          child: Text(
            "Edited Yesterday, 12:52 AM",
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("Clear"),
                      leading: Icon(Icons.delete_outline),
                      onTap: () {
                        // TODO: implement clear in edit note body
                        provider.clear();
                      },
                    ),
                    ListTile(
                      title: Text("Delete"),
                      leading: Icon(Icons.delete_outline),
                      onTap: () async {
                        await provider.delete();
                        context.pop();
                        context.pop();
                      },
                    ),
                    ListTile(
                      title: Text("Make a copy"),
                      leading: Icon(Icons.copy_outlined),
                      onTap: () {
                        // TODO: implement make copy note
                        provider.makeCopy();
                        context.pop();
                      },
                    ),
                    ListTile(
                      title: Text("Send"),
                      leading: Icon(Icons.share),
                      onTap: () {
                        // TODO: implement send note
                        provider.send();
                        context.pop();
                      },
                    ),
                    ListTile(
                      title: Text("Collaborator"),
                      leading: Icon(Icons.person_add_alt_outlined),
                      onTap: () {
                        // TODO: implement collaborator note
                        provider.collaborator();
                        context.pop();
                      },
                    ),
                    ListTile(
                      title: Text("Labels"),
                      leading: Icon(Icons.label_outline),
                      onTap: () async {
                        List<LabelModel>? selected = await context.pushNamed(
                            Routes.selectLabels,
                            extra: provider.currentNote.labelIds);
                        // TODO: implement add labels
                        provider.labels(selected);
                        context.pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
