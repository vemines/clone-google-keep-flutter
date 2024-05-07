import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/shared.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: const _SearchAppBar().preferredSizeAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const _TypeSection(),
              const _LabelSection(),
              const _ThingSection(),
              const _ColorSection(),
            ].separateCenter(),
          ),
        ),
      ),
    );
  }
}

final List<String> _mockLabel = List.generate(5, (index) => index.toString());

class _LabelSection extends StatelessWidget {
  const _LabelSection();

  int getEndRange(int i) {
    int result = (i + 1) * 3;
    return _mockLabel.length <= result ? _mockLabel.length : result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.small),
          child: Text(
            'Labels',
            style: context.textTheme.titleMedium,
          ),
        ),
        for (int i = 0; i * 3 < _mockLabel.length; i++)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ..._mockLabel.getRange(i * 3, getEndRange(i)).map(
                  (label) => _SearchCategory(
                    label,
                    _iconCategory(Icons.label_outline),
                    () {},
                  ),
                ),
            if ((i + 1) * 3 >= _mockLabel.length && _mockLabel.length % 3 == 2)
              Container(width: CircleSize.searchCategoryWidth),
          ]),
      ],
    );
  }
}

class _ThingSection extends StatelessWidget {
  const _ThingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: Dimensions.small),
          title: Text(
            'Things',
            style: context.textTheme.titleMedium,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SearchCategory(
            _mockCategory.entries.elementAt(5).key,
            _mockCategory.entries.elementAt(5).value,
            () {},
          ),
          _SearchCategory(
            _mockCategory.entries.elementAt(6).key,
            _mockCategory.entries.elementAt(6).value,
            () {},
          ),
          Container(width: CircleSize.searchCategoryWidth),
        ]),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(Dimensions.small),
          child: Text(
            'Colors',
            style: context.textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: CircleSize.colorCategorySize,
                  height: CircleSize.colorCategorySize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorName.white),
                  ),
                  child: const Icon(Icons.format_color_reset_outlined),
                ),
              ),
              const _ColorCategory(Colors.red),
              const _ColorCategory(Colors.green),
              const _ColorCategory(Colors.blueAccent),
              const _ColorCategory(Colors.purple),
              const _ColorCategory(Colors.purple),
              const _ColorCategory(Colors.purple),
            ].separateCenter(),
          ),
        ),
      ],
    );
  }
}

class _ColorCategory extends StatelessWidget {
  const _ColorCategory(this.color);
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: CircleSize.colorCategorySize,
        height: CircleSize.colorCategorySize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: ColorName.white),
        ),
      ),
    );
  }
}

class _TypeSection extends StatefulWidget {
  const _TypeSection();

  @override
  State<_TypeSection> createState() => __TypeSectionState();
}

class __TypeSectionState extends State<_TypeSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: Dimensions.small),
          title: Text(
            'Types',
            style: context.textTheme.titleMedium,
          ),
          trailing: TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(_isExpanded ? 'Less' : 'More'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SearchCategory(
              _mockCategory.entries.elementAt(0).key,
              _mockCategory.entries.elementAt(0).value,
              () {},
            ),
            _SearchCategory(
              _mockCategory.entries.elementAt(1).key,
              _mockCategory.entries.elementAt(1).value,
              () {},
            ),
            _SearchCategory(
              _mockCategory.entries.elementAt(2).key,
              _mockCategory.entries.elementAt(2).value,
              () {},
            ),
          ],
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.normal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SearchCategory(
                  _mockCategory.entries.elementAt(3).key,
                  _mockCategory.entries.elementAt(3).value,
                  () {},
                ),
                _SearchCategory(
                  _mockCategory.entries.elementAt(4).key,
                  _mockCategory.entries.elementAt(4).value,
                  () {},
                ),
                Container(width: CircleSize.searchCategoryWidth),
              ],
            ),
          ),
      ],
    );
  }
}

Widget _iconCategory(IconData iconData) => Icon(
      iconData,
      color: ColorName.white,
      size: IconSize.searchCategory,
    );

Map<String, Widget> _mockCategory = {
  "Reminds": _iconCategory(
    Icons.notifications_outlined,
  ),
  "Lists": _iconCategory(
    Icons.check_box_outlined,
  ),
  "Images": _iconCategory(
    Icons.image_outlined,
  ),
  "Record": _iconCategory(
    Icons.keyboard_voice_outlined,
  ),
  "Drawings": _iconCategory(
    Icons.edit_outlined,
  ),
  // Things
  "Food": _iconCategory(
    Icons.restaurant_outlined,
  ),
  "Music": _iconCategory(
    Icons.headphones_outlined,
  ),
};

class _SearchCategory extends StatelessWidget {
  const _SearchCategory(this.title, this.icon, this.onTap);
  final String title;
  final Widget icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: CircleSize.searchCategoryWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: ColorName.primaryDark,
              radius: CircleSize.searchCategory,
              child: Center(
                child: icon,
              ),
            ),
            gapS(),
            Flexible(
              child: Center(
                child: Text(
                  title,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: context.theme.unselectedWidgetColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: () {
          context.pop();
        },
      ),
      backgroundColor: ColorName.textfieldBgDark,
      leadingWidth: AppbarSize.leadingWidth,
      title: const TextField(
        decoration: InputDecoration(
          hintText: "Search your notes",
          border: InputBorder.none,
          fillColor: ColorName.textfieldBgDark,
        ),
      ),
    );
  }
}
