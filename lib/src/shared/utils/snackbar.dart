import 'package:flutter/material.dart';
import 'package:keep_app/src/shared/shared.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
  required TextStyle? messageStyle,
  int? miliDuration,
  required Color? bgColor,
}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: messageStyle,
        ),
        duration: Duration(milliseconds: miliDuration ?? 500),
        backgroundColor: bgColor,
      ),
    );

void showCenterLoading({
  required BuildContext context,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CenterIndicator(),
  );
}
