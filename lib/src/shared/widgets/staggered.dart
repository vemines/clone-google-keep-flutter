import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../gen/assets.gen.dart';
import '../../data/models/image_model.dart';

List<StaggeredGridTile> generateStaggeredGridTilesDemo(List<String> urls) {
  List<StaggeredGridTile> tiles = [];
  final firstline = urls.length % 3;
  if (firstline == 1) {
    // take url 1
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 6,
        mainAxisCellCount: 7,
        child: Assets.jpg.portrait.image(fit: BoxFit.fitWidth),
      ),
    );
  } else if (firstline == 2) {
    // take url 1
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 6,
        child: Assets.jpg.portrait2.image(fit: BoxFit.fitWidth),
      ),
    );
    // take url 2
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 6,
        child: Assets.jpg.portrait3.image(fit: BoxFit.fitWidth),
      ),
    );
  }

  for (var i = 0 + firstline; i < urls.length; i++) {
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 2,
        mainAxisCellCount: 4,
        child: Assets.jpg.portrait.image(fit: BoxFit.fitWidth),
      ),
    );
  }

  return tiles;
}

List<StaggeredGridTile> generateStaggeredGridTiles(List<ImageModel> urls) {
  List<StaggeredGridTile> tiles = [];
  final firstline = urls.length % 3;
  if (firstline == 1) {
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 6,
        mainAxisCellCount: 7,
        child: Image.file(
          File(urls[0].url),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  } else if (firstline == 2) {
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 6,
        child: Image.file(
          File(urls[0].url),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 6,
        child: Image.file(
          File(urls[1].url),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  for (var i = 0 + firstline; i < urls.length; i++) {
    tiles.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 2,
        mainAxisCellCount: 4,
        child: Image.file(
          File(urls[i].url),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  return tiles;
}
