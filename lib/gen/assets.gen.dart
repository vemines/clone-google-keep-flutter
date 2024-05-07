/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsJpgGen {
  const $AssetsJpgGen();

  /// File path: assets/jpg/bg1.jpg
  AssetGenImage get bg1 => const AssetGenImage('assets/jpg/bg1.jpg');

  /// File path: assets/jpg/bg2.jpg
  AssetGenImage get bg2 => const AssetGenImage('assets/jpg/bg2.jpg');

  /// File path: assets/jpg/bg3.jpg
  AssetGenImage get bg3 => const AssetGenImage('assets/jpg/bg3.jpg');

  /// File path: assets/jpg/portrait.jpg
  AssetGenImage get portrait => const AssetGenImage('assets/jpg/portrait.jpg');

  /// File path: assets/jpg/portrait2.jpg
  AssetGenImage get portrait2 =>
      const AssetGenImage('assets/jpg/portrait2.jpg');

  /// File path: assets/jpg/portrait3.jpg
  AssetGenImage get portrait3 =>
      const AssetGenImage('assets/jpg/portrait3.jpg');

  /// List of all assets
  List<AssetGenImage> get values =>
      [bg1, bg2, bg3, portrait, portrait2, portrait3];
}

class $AssetsPngGen {
  const $AssetsPngGen();

  /// File path: assets/png/add.png
  AssetGenImage get add => const AssetGenImage('assets/png/add.png');

  /// File path: assets/png/avatar.png
  AssetGenImage get avatar => const AssetGenImage('assets/png/avatar.png');

  /// File path: assets/png/google.png
  AssetGenImage get google => const AssetGenImage('assets/png/google.png');

  /// File path: assets/png/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/png/logo.png');

  /// File path: assets/png/splash_dark.png
  AssetGenImage get splashDark =>
      const AssetGenImage('assets/png/splash_dark.png');

  /// File path: assets/png/splash_light.png
  AssetGenImage get splashLight =>
      const AssetGenImage('assets/png/splash_light.png');

  /// File path: assets/png/user.png
  AssetGenImage get user => const AssetGenImage('assets/png/user.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [add, avatar, google, logo, splashDark, splashLight, user];
}

class Assets {
  Assets._();

  static const $AssetsJpgGen jpg = $AssetsJpgGen();
  static const $AssetsPngGen png = $AssetsPngGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
