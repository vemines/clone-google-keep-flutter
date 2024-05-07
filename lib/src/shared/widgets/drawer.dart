import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/label_model.dart';
import '../../data/services/label_svc.dart';
import '../shared.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final labelService = LabelService.instance;

    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Dimensions.large),
            child: Text(
              'VeMines Keep App',
              style: textTheme.bodyLarge,
            ),
          ),
          ListTile(
            title: const Text('Notes'),
            leading: const Icon(Icons.lightbulb_outline),
            onTap: () => pushRoute(context, Routes.home),
          ),
          ListTile(
            title: const Text('Reminds'),
            leading: const Icon(Icons.notifications_outlined),
            onTap: () => pushRoute(context, Routes.remind),
          ),
          divider(),
          BlocBuilder<AuthBloc, AuthState>(
            bloc: authBloc,
            builder: (_, state) {
              if (state is AuthStateAuthenticated) {
                final uid = state.uid;
                return StreamBuilder<List<LabelModel>>(
                    stream: labelService.labelsStream(uid),
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        return _LabelSection(snapshot.data ?? []);
                      }
                      return _LabelSection([]);
                    });
              }

              return _LabelSection([]);
            },
          ),
          divider(),
          ListTile(
            title: const Text('Archive'),
            leading: const Icon(Icons.archive_outlined),
            onTap: () => pushRoute(context, Routes.archive),
          ),
          ListTile(
            title: const Text('Trash'),
            leading: const Icon(Icons.delete_outline),
            onTap: () => pushRoute(context, Routes.trash),
          ),
          ListTile(
            title: const Text('Setings'),
            leading: const Icon(Icons.settings_outlined),
            onTap: () => context.pushNamed(Routes.settings),
          ),
        ],
      ),
    );
  }

  void pushRoute(BuildContext context, String route) {
    if (GoRouter.of(context).routeInformationProvider.value.uri != route) {
      context.pop();
      context.goNamed(route);
    }
  }
}

class _LabelSection extends StatelessWidget {
  const _LabelSection(this.labels);

  final List<LabelModel> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Labels'),
          trailing: TextButton(
            onPressed: () {
              context.pushNamed(Routes.editLabels);
            },
            child: const Text("Edit"),
          ),
        ),
        ...labels
            .map((l) => ListTile(
                  title: Text(
                    l.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(Icons.label_outline),
                  onTap: () {
                    context.pop();
                    context.pushNamed(Routes.label, extra: l);
                  },
                ))
            .toList(),
        ListTile(
          title: const Text("Create new label"),
          leading: const Icon(Icons.add_outlined),
          onTap: () {
            context.pushNamed(Routes.editLabels);
          },
        ),
      ],
    );
  }
}
