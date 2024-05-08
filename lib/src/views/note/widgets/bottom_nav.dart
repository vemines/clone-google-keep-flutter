part of '../note_view.dart';

class _NoteBottom extends StatelessWidget {
  const _NoteBottom(
    this.provider, {
    required this.onChangeBgImage,
    required this.onChangeBgColor,
  });
  final NoteProvider provider;
  final Function(int) onChangeBgImage;
  final Function(int) onChangeBgColor;

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
                            GestureDetector(
                              onTap: () {
                                onChangeBgColor(0);
                                context.pop();
                              },
                              child: Container(
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
                            ),
                            ...BgColor.values.map(
                              (e) => e.index != 0
                                  ? GestureDetector(
                                      onTap: () {
                                        onChangeBgColor(e.index);
                                        context.pop();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor:
                                            intToBgNoteColor(e.index),
                                        minRadius: 25,
                                      ),
                                    )
                                  : SizedBox(),
                            ),
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
                          GestureDetector(
                            onTap: () {
                              onChangeBgImage(0);
                              context.pop();
                            },
                            child: Container(
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
                          ),
                          ...BgNote.values.map(
                            (e) => e.index != 0
                                ? GestureDetector(
                                    onTap: () {
                                      onChangeBgImage(e.index);
                                      context.pop();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      child: Image.asset(
                                          intToBgNoteImage(e.index) ?? ""),
                                    ),
                                  )
                                : SizedBox(),
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
