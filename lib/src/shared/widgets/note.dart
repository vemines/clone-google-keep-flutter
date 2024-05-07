import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/note_model.dart';
import '../../data/services/label_svc.dart';
import '../shared.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget(
    this.note, {
    this.selected = true,
    super.key,
    required this.onTap,
    required this.onLongPress,
  });

  final NoteModel note;
  final bool selected;
  final Function() onTap;
  final Function() onLongPress;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final listImageGrid = note.imageUrls ?? [];
    final checkedTodos = note.todos?.where((todo) => todo.checked == true);
    final uncheckedTodos = note.todos?.where((todo) => todo.checked == false);
    final LabelService labelService = LabelService.instance;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final uid = (authBloc.state as AuthStateAuthenticated).uid;

    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusBorder.normal),
          border: Border.all(
            color: selected
                ? Colors.blue[300]!
                : context.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.normal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (listImageGrid.length > 0)
                  StaggeredGrid.count(
                    crossAxisCount: 6,
                    crossAxisSpacing: Dimensions.small,
                    mainAxisSpacing: Dimensions.small,
                    children: generateStaggeredGridTiles(listImageGrid),
                  ),
                if ((note.title ?? "").isNotEmpty)
                  Text(
                    note.title!,
                    style: textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if ((note.content ?? "").isNotEmpty)
                  Text(
                    note.content!,
                    style: const TextStyle(color: ColorName.onPrimaryDark),
                    maxLines: 9,
                    overflow: TextOverflow.ellipsis,
                  ),
                if ((uncheckedTodos?.length ?? 0) > 0)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: uncheckedTodos!
                        .map(
                          (todo) => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Checkbox(value: false, onChanged: null),
                              gapSM(),
                              Flexible(
                                child: Text(
                                  todo.text,
                                  style: textTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                if ((note.todos?.length ?? 0) > 0 &&
                    (checkedTodos?.length ?? 0) > 0)
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: Dimensions.small),
                      child: Text(
                        "+ ${checkedTodos?.length} checked item",
                        style: textTheme.bodyMedium!.copyWith(
                            color: context.theme.unselectedWidgetColor),
                      ),
                    ),
                  ),
                if ((note.records?.length ?? 0) > 0 || note.remind != null)
                  Wrap(
                    children: [
                      if ((note.records?.length ?? 0) > 0)
                        for (var i = 0; i < note.records!.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.play_circle,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                      gapN(),
                      if (note.remind != null)
                        GreyFilledButton(
                          onPressed: null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.alarm_outlined,
                                color: context.colorScheme.onSurface,
                                size: IconSize.remindInNote,
                              ),
                              gapS(),
                              Text(
                                "Today, 18:00",
                                style: context.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                if ((note.labelIds?.length ?? 0) > 0)
                  Wrap(
                    spacing: Dimensions.small,
                    runSpacing: Dimensions.small,
                    children: [
                      ...note.labelIds!.map(
                        (labelId) => GreyFilledButton(
                          onPressed: null,
                          child: FutureBuilder<String>(
                            future: labelService.getLabelById(uid, labelId),
                            builder: (_, snapshot) {
                              return Text(
                                snapshot.data ?? "",
                                style: context.textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
              ].separateCenter(),
            ),
          ),
        ),
      ),
    );
  }
}
