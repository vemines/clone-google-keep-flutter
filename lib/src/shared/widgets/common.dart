import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';

import '../constants/sizes.dart';
import '../extensions/context_ext.dart';

var brightness =
    SchedulerBinding.instance.platformDispatcher.platformBrightness;
bool isDarkMode = brightness == Brightness.dark;

Widget iconBox({
  required IconData iconData,
  required Function()? onTap,
  Color? disableColor,
}) =>
    InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          iconData,
          color: onTap == null ? disableColor : null,
        ),
      ),
    );

Widget gapF(double factor) =>
    Gap(Dimensions.normal * factor); // gap with factor
Widget gapN() => const Gap(12); // gap normal
Widget gapS() => const Gap(Dimensions.small); // gap small
Widget gapSM() => const Gap(Dimensions.small / 2); // gap small
Widget gapL() => const Gap(Dimensions.large); // gap large

Widget divider([double height = 4]) {
  return Divider(
    height: height,
    color: isDarkMode
        ? Colors.white.withOpacity(0.4)
        : Colors.black.withOpacity(0.4),
  );
}

Widget widgetByThemeMode({required Widget light, required Widget dark}) {
  return isDarkMode ? dark : light;
}

class CenterIndicator extends StatelessWidget {
  const CenterIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class GreyFilledButton extends StatelessWidget {
  const GreyFilledButton({
    super.key,
    required this.child,
    required this.onPressed,
  });
  final Widget child;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.grey[600],
        padding: const EdgeInsets.all(Dimensions.small),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusBorder.labelInNote),
        ),
      ),
      child: child,
    );
  }
}

class EmptyNoteBodyCenter extends StatelessWidget {
  const EmptyNoteBodyCenter({
    super.key,
    required this.iconData,
    required this.text,
  });
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 150,
          ),
          gapN(),
          Text(
            text,
            style: context.textTheme.bodyLarge,
          )
        ],
      ),
    );
  }
}
