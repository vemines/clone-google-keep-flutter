import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../shared/shared.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

final _selected = const Color.fromRGBO(0, 194, 203, 1);

class _AuthViewState extends State<AuthView> {
  int currentSelected = 0;

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return SafeArea(
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (blocContext, state) {
            print(state);
            if (state == AuthStateLoading) {
              showCenterLoading(context: context);
            } else if (state is SignInSuccessState) {
              showSnackBar(
                context: context,
                message: "Sign in Success",
                messageStyle: context.textTheme.bodyLarge,
                bgColor: Colors.green,
              );
            } else if (state is SignUpSuccessState) {
              showSnackBar(
                context: context,
                message: "Sign up Success",
                messageStyle: context.textTheme.bodyLarge,
                bgColor: Colors.green,
              );
            } else if (state is SignInErrorState) {
              showSnackBar(
                context: context,
                message: "Fail to Sign in: ${state.error}",
                messageStyle: context.textTheme.bodyLarge,
                bgColor: context.colorScheme.error,
                miliDuration: 5000,
              );
            } else if (state is SignUpErrorState) {
              showSnackBar(
                context: context,
                message: "Fail to Sign up: ${state.error}",
                messageStyle: context.textTheme.bodyLarge,
                bgColor: context.colorScheme.error,
                miliDuration: 5000,
              );
            }
          },
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: context.theme.splashColor,
                borderRadius: BorderRadius.circular(RadiusBorder.normal),
              ),
              padding: const EdgeInsets.all(Dimensions.large),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LogoTitleRow(),
                    gapF(2.5),
                    CupertinoSlidingSegmentedControl<int>(
                      // backgroundColor: bgcolor,
                      thumbColor: _selected,
                      groupValue: currentSelected,
                      children: const {
                        0: Padding(
                          padding: EdgeInsets.all(Dimensions.small),
                          child: Text("Sign In"),
                        ),
                        1: Padding(
                          padding: EdgeInsets.all(Dimensions.small),
                          child: Text("Sign Up"),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          currentSelected = value!;
                        });
                      },
                    ),
                    gapL(),
                    currentSelected == 0
                        ? _SignInSection(authBloc)
                        : _SignUpSection(authBloc),
                    gapF(1),
                    divider(),
                    gapF(1),
                    _OtherSignInSection(authBloc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtherSignInSection extends StatelessWidget {
  const _OtherSignInSection(this.authBloc);
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionFilledButton(
            widthFactor: 0.8,
            title: "Sign In as Guest",
            onPressed: () {
              authBloc.add(SignInAsGuestEvent());
            },
          ),
        ),
        gapN(),
        Expanded(
          child: _ActionFilledButton(
            widthFactor: 0.8,
            title: "Sign In with Google",
            onPressed: () {
              authBloc.add(SignInWithGoogleEvent());
            },
          ),
        ),
      ],
    );
  }
}

class _LogoTitleRow extends StatelessWidget {
  const _LogoTitleRow();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.png.logo.image(width: 50),
        gapL(),
        Text(
          "My Note",
          style: textTheme.displaySmall,
        ),
      ],
    );
  }
}

class _SignInSection extends StatefulWidget {
  const _SignInSection(this.authBloc);
  final AuthBloc authBloc;
  @override
  State<_SignInSection> createState() => _SignInSectionState();
}

class _SignInSectionState extends State<_SignInSection> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ),
        gapN(),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ),
        gapF(2),
        _ActionFilledButton(
          title: "Sign In",
          bgColor: ColorName.primaryDark,
          widthFactor: 0.5,
          onPressed: () {
            widget.authBloc.add(SignInWithEmailEvent(
              email: emailController.text,
              password: passwordController.text,
            ));
          },
        ),
      ],
    );
  }
}

class _SignUpSection extends StatefulWidget {
  const _SignUpSection(this.authBloc);
  final AuthBloc authBloc;

  @override
  State<_SignUpSection> createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<_SignUpSection> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ),
        gapN(),
        TextField(
          obscureText: true,
          controller: passwordController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ),
        gapN(),
        TextField(
          obscureText: true,
          controller: confirmController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            hintText: "Confirm password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusBorder.normal),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
          ),
        ),
        gapF(2),
        _ActionFilledButton(
          title: "Sign Up",
          bgColor: ColorName.primaryDark,
          widthFactor: 0.5,
          onPressed: () {
            if (passwordController.text != confirmController.text) {
              showSnackBar(
                context: context,
                message: "Passwords do not match",
                messageStyle: context.textTheme.bodyLarge,
                bgColor: context.colorScheme.error,
              );
              return;
            }
            widget.authBloc.add(SignUpWithEmailEvent(
              email: emailController.text,
              password: passwordController.text,
            ));
          },
        ),
      ],
    );
  }
}

class _ActionFilledButton extends StatelessWidget {
  const _ActionFilledButton({
    required this.title,
    this.bgColor,
    required this.widthFactor,
    required this.onPressed,
  });

  final String title;
  final Color? bgColor;
  final double widthFactor;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusBorder.normal),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.small,
            vertical: Dimensions.normal,
          ),
          backgroundColor: bgColor,
        ),
        child: Text(
          title,
          style: textTheme.labelMedium,
        ),
      ),
    );
  }
}
