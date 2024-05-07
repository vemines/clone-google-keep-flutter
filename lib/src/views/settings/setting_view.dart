import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/cubit/locale/locale_cubit.dart';
import '../../bloc/cubit/theme/theme_cubit.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/setting_model.dart';
import '../../data/models/auth_model.dart';
import '../../data/services/settings_svc.dart';
import '../../shared/shared.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  late SettingsModel settings;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    String uid = (authBloc.state as AuthStateAuthenticated).uid;
    SettingsService settingsService = SettingsService(uid);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          leadingWidth: AppbarSize.leadingWidth,
        ),
        drawer: AppDrawer(),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: (authBloc.state as AuthStateAuthenticated).authStream,
            builder: (BuildContext StreamContext,
                AsyncSnapshot<AuthModel?> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              settings = snapshot.data!.settings ?? defaultSettings;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.normal),
                    child:
                        Text("Display options", style: textTheme.headlineSmall),
                  ),
                  SwitchListTile(
                    value: settings.addNoteToBottom,
                    onChanged: (value) {
                      settings.addNoteToBottom = value;
                      settingsService.updateSettingField(
                        uid,
                        "addNoteToBottom",
                        value,
                      );
                    },
                    title: const Text("Add new items to bottom"),
                  ),
                  SwitchListTile(
                    value: settings.moveCheckedToBottom,
                    onChanged: (value) {
                      settings.moveCheckedToBottom = value;
                      settingsService.updateSettingField(
                        uid,
                        "moveCheckedToBottom",
                        value,
                      );
                    },
                    title: const Text("Move checked items to bottom"),
                  ),
                  SwitchListTile(
                    value: settings.displayRichLink,
                    onChanged: (value) {
                      settings.displayRichLink = value;
                      settingsService.updateSettingField(
                        uid,
                        "displayRichLink",
                        value,
                      );
                    },
                    title: const Text("Display rich link Settings"),
                  ),
                  _SettingChooseDialog(
                    label: "Theme",
                    value: settings.theme,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChooseOptionsDialog(
                          dialogTitle: "Theme",
                          options: supportsTheme.entries
                              .map(
                                (entry) => RadioListTile(
                                  value: entry.value,
                                  title: Text(entry.value),
                                  groupValue: settings.theme,
                                  onChanged: (value) {
                                    if (value != null) {
                                      settings.theme = value;
                                      settingsService.updateSettingField(
                                          uid, "theme", value);
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                  _SettingChooseDialog(
                    label: "Language",
                    value: languageName(settings.language),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChooseOptionsDialog(
                          dialogTitle: "Select Language",
                          options: supportLanguages
                              .map(
                                (locale) => RadioListTile(
                                  value: locale.languageCode,
                                  title:
                                      Text(languageName(locale.languageCode)),
                                  groupValue: settings.language,
                                  onChanged: (value) {
                                    if (value != null) {
                                      settings.language = value;
                                      settingsService.updateSettingField(
                                        uid,
                                        "language",
                                        value,
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                  gapL(),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.normal),
                    child:
                        Text("Remind defaults", style: textTheme.headlineSmall),
                  ),
                  //
                  _SettingChooseDialog(
                    label: "Morning",
                    value: settings.morningRemind.toString(),
                    onTap: () async {
                      final timePicked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                      );
                      if (timePicked != null) {
                        settings.morningRemind = timeOfDayToString(timePicked);
                        settingsService.updateSettingField(
                          uid,
                          "morningRemind",
                          timeOfDayToString(timePicked),
                        );
                      }
                    },
                  ),
                  _SettingChooseDialog(
                    label: "Afternoon",
                    value: settings.afternoonRemind.toString(),
                    onTap: () async {
                      final timePicked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 13, minute: 0),
                      );
                      if (timePicked != null) {
                        settings.afternoonRemind =
                            timeOfDayToString(timePicked);
                        settingsService.updateSettingField(
                          uid,
                          "afternoonRemind",
                          timeOfDayToString(timePicked),
                        );
                      }
                    },
                  ),
                  _SettingChooseDialog(
                    label: "Evening",
                    value: settings.eveningRemind.toString(),
                    onTap: () async {
                      final timePicked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 18, minute: 0),
                      );
                      if (timePicked != null) {
                        settings.eveningRemind = timeOfDayToString(timePicked);
                        settingsService.updateSettingField(
                          uid,
                          "eveningRemind",
                          timeOfDayToString(timePicked),
                        );
                      }
                    },
                  ),
                  //
                  gapL(),
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.normal),
                    child: Text("Sharing", style: textTheme.headlineSmall),
                  ),
                  SwitchListTile(
                    value: settings.enableSharing,
                    onChanged: (value) {
                      settings.enableSharing = value;
                      settingsService.updateSettingField(
                        uid,
                        "enableSharing",
                        value,
                      );
                    },
                    title: const Text("Enable Sharing"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingChooseDialog extends StatelessWidget {
  const _SettingChooseDialog({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.bodyLarge;
    return InkWell(
      onTap: onTap,
      child: ListTile(
        title: Text(label, style: textStyle),
        trailing: Text(value, style: textStyle),
      ),
    );
  }
}
