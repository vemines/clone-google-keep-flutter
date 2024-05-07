import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../shared/shared.dart';

class ResetPassView extends StatelessWidget {
  const ResetPassView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SafeArea(
      child: Scaffold(
        body: Center(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.png.logo.image(width: 50),
                      gapL(),
                      Text(
                        "My Note",
                        style: textTheme.displaySmall,
                      ),
                    ],
                  ),
                  gapL(),
                  _ResetPassSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPassSection extends StatefulWidget {
  const _ResetPassSection();

  @override
  State<_ResetPassSection> createState() => _ResetPassSectionState();
}

class _ResetPassSectionState extends State<_ResetPassSection> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
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
        gapF(2),
        FractionallySizedBox(
          widthFactor: 0.5,
          child: FilledButton(
            onPressed: () =>
                authBloc.add(ResetPassEvent(email: emailController.text)),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusBorder.normal),
              ),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.large),
              backgroundColor: ColorName.primaryDark,
            ),
            child: Text(
              "Reset password",
              style: context.textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}
