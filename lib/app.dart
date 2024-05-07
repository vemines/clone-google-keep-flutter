import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'gen/l10n.dart';
import 'src/bloc/cubit/locale/locale_cubit.dart';
import 'src/bloc/cubit/theme/theme_cubit.dart';
import 'src/bloc/auth/auth_bloc.dart';
import 'src/data/services/auth_svc.dart';
import 'src/routes/app_pages.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleCubit _localeCubit = LocaleCubit();
  final ThemeCubit _themeCubit = ThemeCubit();
  final AuthBloc _authBloc = AuthBloc(AuthService.instance);

  @override
  void initState() {
    super.initState();
    _localeCubit.loadCurrentLocale();
    _themeCubit.loadCurrentTheme();
    _authBloc.add(AuthInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (context) => _localeCubit,
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => _themeCubit,
        ),
        BlocProvider<AuthBloc>(
          create: (context) => _authBloc,
        ),
      ],
      child: Builder(
        builder: (builderContext) {
          final locale = builderContext.watch<LocaleCubit>();
          final appTheme = builderContext.watch<ThemeCubit>();
          final authBloc = builderContext.read<AuthBloc>();

          return BlocBuilder<AuthBloc, AuthState>(
            bloc: authBloc,
            builder: (blocContext, state) {
              var route = AppPages.authRoute;
              if (authBloc.state.authStatus == AuthStatus.authenticated) {
                route = AppPages.router();
              }

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                scrollBehavior: AppScrollBehavior(),
                routerConfig: route,
                theme: themeData[appTheme.state],
                themeMode: {
                  ThemeMode.dark: ThemeMode.dark,
                  ThemeMode.system: ThemeMode.system,
                  ThemeMode.light: ThemeMode.light,
                }[appTheme.themeMode],
                locale: locale.state,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: supportLanguages,
              );
            },
          );
        },
      ),
    );
  }
}

Widget buildMaterialAppRouter({
  required GoRouter route,
  required ThemeData? themeData,
  required ThemeMode? appThemeMode,
  required Locale locale,
}) {
  return MaterialApp.router(
    debugShowCheckedModeBanner: false,
    scrollBehavior: AppScrollBehavior(),
    routerConfig: route,
    theme: themeData,
    themeMode: appThemeMode,
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: supportLanguages,
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
