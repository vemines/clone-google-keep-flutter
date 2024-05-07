import 'package:flutter/material.dart';
import 'package:keep_app/src/shared/shared.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.title,
    required this.scaffoldKey,
    this.showSearch = false,
    this.showGrid = false,
    this.gridValue = true,
    this.moreVert,
    this.onSearch,
    this.onGrid,
  });
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool showSearch;
  final bool showGrid;
  final bool gridValue;
  final Widget? moreVert;
  final Function()? onSearch;
  final Function()? onGrid;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_outlined),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      leadingWidth: AppbarSize.leadingWidth,
      title: Text(title),
      actions: [
        if (showSearch && onSearch != null)
          IconButton(
            onPressed: onSearch,
            icon: const Icon(
              Icons.search_outlined,
            ),
          ),
        if (showGrid && onGrid != null)
          IconButton(
            onPressed: onGrid,
            icon: Icon(
              gridValue
                  ? Icons.splitscreen_outlined
                  : Icons.format_list_bulleted_outlined,
            ),
          ),
        if (moreVert != null) moreVert!,
      ].separateCenter(),
    );
  }
}

class MultiSelectAppBar extends StatelessWidget {
  const MultiSelectAppBar({
    super.key,
    required this.onLeading,
    required this.selected,
    required this.onPinned,
    required this.onArchived,
    required this.onRemind,
    required this.onLabels,
    required this.onDelete,
    required this.onChangeNoteBg,
    required this.onMakeCopy,
    required this.onSend,
  });
  final Function() onLeading;
  final Function() onPinned;
  final Function() onArchived;
  final Function() onRemind;
  final Function() onLabels;
  final Function() onDelete;
  final Function() onChangeNoteBg;
  final Function() onMakeCopy;
  final Function() onSend;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: onLeading,
      ),
      title: Text(selected.toString()),
      actions: [
        IconButton(
          icon: Icon(Icons.push_pin_outlined),
          onPressed: onPinned,
        ),
        IconButton(
          icon: Icon(Icons.notification_add_outlined),
          onPressed: onRemind,
        ),
        IconButton(
          icon: Icon(Icons.palette_outlined),
          onPressed: onChangeNoteBg,
        ),
        IconButton(
          icon: Icon(Icons.label_outline),
          onPressed: onLabels,
        ),
        MoreVertMenuPopup(
            mapItems: {
              1: "Archive",
              2: "Delete",
              3: "Make a copy",
              4: "Send",
            },
            onSelected: (value) {
              switch (value) {
                case 1:
                  onArchived();
                  break;
                case 2:
                  onDelete();
                  break;
                case 3:
                  onMakeCopy();
                  break;
                case 4:
                  onSend();
                  break;
              }
            })
      ],
    );
  }
}
