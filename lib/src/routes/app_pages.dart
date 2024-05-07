import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/label_model.dart';
import '../views/views.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final GoRouter authRoute = GoRouter(
    initialLocation: Routes.auth,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.auth,
        name: Routes.auth,
        builder: (BuildContext context, GoRouterState state) {
          return const AuthView();
        },
      ),
      GoRoute(
        path: Routes.resetPass,
        name: Routes.resetPass,
        builder: (BuildContext context, GoRouterState state) {
          return const ResetPassView();
        },
      ),
      GoRoute(
        path: "/",
        name: "/",
        builder: (BuildContext context, GoRouterState state) {
          return const AuthView();
        },
      ),
    ],
  );

  static GoRouter router() => GoRouter(
        initialLocation: Routes.home,
        routes: <RouteBase>[
          GoRoute(
            path: Routes.home,
            name: Routes.home,
            builder: (BuildContext context, GoRouterState state) {
              return HomeView();
            },
          ),
          GoRoute(
            path: Routes.archive,
            name: Routes.archive,
            builder: (BuildContext context, GoRouterState state) {
              return const ArchiveView();
            },
          ),
          GoRoute(
            path: Routes.trash,
            name: Routes.trash,
            builder: (BuildContext context, GoRouterState state) {
              return const TrashView();
            },
          ),
          GoRoute(
            path: Routes.label,
            name: Routes.label,
            builder: (BuildContext context, GoRouterState state) {
              final LabelModel extra = state.extra as LabelModel;
              return LabelView(extra);
            },
          ),
          GoRoute(
            path: Routes.editLabels,
            name: Routes.editLabels,
            builder: (BuildContext context, GoRouterState state) {
              return const EditLabelsView();
            },
          ),
          GoRoute(
            path: Routes.selectLabels,
            name: Routes.selectLabels,
            builder: (BuildContext context, GoRouterState state) {
              final List<String> extra = (state.extra as List<String>?) ?? [];
              return SelectLabelsView(labelSelectedIds: extra);
            },
          ),
          GoRoute(
            path: Routes.note,
            name: Routes.note,
            builder: (BuildContext context, GoRouterState state) {
              return const NoteView();
            },
          ),
          GoRoute(
            path: Routes.remind,
            name: Routes.remind,
            builder: (BuildContext context, GoRouterState state) {
              return const RemindView();
            },
          ),
          GoRoute(
            path: Routes.search,
            name: Routes.search,
            builder: (BuildContext context, GoRouterState state) {
              return const SearchView();
            },
          ),
          GoRoute(
            path: Routes.settings,
            name: Routes.settings,
            builder: (BuildContext context, GoRouterState state) {
              return const SettingView();
            },
          ),
          GoRoute(
            path: Routes.drawPad,
            name: Routes.drawPad,
            builder: (BuildContext context, GoRouterState state) {
              return const DrawPadView();
            },
          ),
        ],
      );
}
