import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared.dart';

class MoreVertMenuPopup extends StatelessWidget {
  const MoreVertMenuPopup({
    super.key,
    required this.mapItems,
    required this.onSelected,
    this.iconData,
  });
  final Map<dynamic, String> mapItems;
  final Function(dynamic) onSelected;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      icon: Icon(iconData ?? Icons.more_vert),
      itemBuilder: (context) => mapItems.entries
          .map(
            (entry) => PopupMenuItem<dynamic>(
              value: entry.key,
              child: Text(entry.value.toString()),
            ),
          )
          .toList(),
      onSelected: onSelected,
    );
  }
}

class ChooseOptionsDialog extends StatelessWidget {
  const ChooseOptionsDialog({
    super.key,
    required this.dialogTitle,
    required this.options,
  });
  final String dialogTitle;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return AlertDialog(
      title: Text(dialogTitle),
      titlePadding: const EdgeInsets.all(Dimensions.normal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusBorder.normal),
      ),
      backgroundColor: ColorName.backgroundDark,
      actionsPadding: const EdgeInsets.fromLTRB(
        Dimensions.normal,
        0,
        Dimensions.normal,
        Dimensions.small,
      ),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      actions: [
        TextButton(
          style: TextButton.styleFrom().copyWith(
            padding: const MaterialStatePropertyAll(
              EdgeInsets.all(Dimensions.large),
            ),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
            )),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel", style: textTheme.labelLarge),
        ),
      ],
    );
  }
}

class AccountDialog extends StatelessWidget {
  const AccountDialog({
    super.key,
    required this.onLogout,
    required this.onEditProfile,
    required this.onAddAccount,
    required this.onManagerAccount,
  });

  final Function() onLogout;
  final Function() onEditProfile;
  final Function() onAddAccount;
  final Function() onManagerAccount;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return AlertDialog(
      title: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Keep App"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        toolbarHeight: 50,
      ),
      titlePadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusBorder.accountDialog),
      ),
      backgroundColor: const Color(0xff3b3c40),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TextButton(
                onPressed: () {
                  // TODO: Privacy Policy Dialog
                },
                child: Text("Privacy Policy", style: textTheme.labelLarge),
              ),
            ),
            const Badge(
              smallSize: 5,
              backgroundColor: Colors.white,
            ),
            Flexible(
              child: TextButton(
                onPressed: () {
                  // TODO: Term of Service Dialog
                },
                child: Text("Term of Service", style: textTheme.labelLarge),
              ),
            ),
          ],
        ),
      ],
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: 350,
          maxWidth: 500,
        ),
        padding: const EdgeInsets.all(Dimensions.normal),
        margin: const EdgeInsets.all(Dimensions.small),
        decoration: BoxDecoration(
          color: const Color(0xff2d2e30),
          borderRadius: BorderRadius.circular(RadiusBorder.accountDialog),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Assets.png.avatar
                    .image(width: ImageSize.selectAcountDialog),
                title: const Text("VeMines"),
                subtitle: const Text("VeMines@outlook.com"),
                onTap: () {},
                contentPadding: EdgeInsets.zero,
              ),
              gapN(),
              divider(),
              gapN(),
              InkWell(
                child: Text(
                  "Manage account",
                  style: textTheme.bodySmall!.copyWith(fontSize: 16),
                ),
                onTap: () {},
              ),
              gapL(),
              ListTile(
                title: const Text("Add another account"),
                leading: const Icon(Icons.person_add_outlined),
                onTap: onAddAccount,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text("Edit profile"),
                leading: const Icon(Icons.edit_outlined),
                onTap: onEditProfile,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text("Manager account"),
                leading: const Icon(Icons.manage_accounts_outlined),
                onTap: onManagerAccount,
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text("Log out"),
                leading: const Icon(Icons.logout_outlined),
                onTap: onLogout,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class AddImageMethodDialog extends StatelessWidget {
  const AddImageMethodDialog({
    super.key,
    required this.takePhoto,
    required this.chooseImage,
  });

  final Function() takePhoto;
  final Function() chooseImage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add image"),
      titlePadding: const EdgeInsets.all(Dimensions.normal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusBorder.normal),
      ),
      backgroundColor: ColorName.backgroundDark,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Take Photo"),
                onTap: takePhoto,
                leading: Icon(Icons.camera_alt_outlined),
              ),
              ListTile(
                title: Text("Choose image"),
                onTap: chooseImage,
                leading: Icon(Icons.image_outlined),
              ),
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

void showSingleTextFieldDialog(
  BuildContext context,
  String dialogTitle, {
  String? initText,
  String? confirmText,
  required Function(String) onConfirm,
}) {
  TextEditingController _textFieldController = TextEditingController(
    text: initText,
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(dialogTitle),
        content: TextField(
          controller: _textFieldController,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              context.pop();
            },
          ),
          TextButton(
            child: Text(confirmText ?? 'Confirm'),
            onPressed: () {
              onConfirm(_textFieldController.text);
              context.pop();
            },
          ),
        ],
      );
    },
  );
}
