import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/label_model.dart';
import '../../data/services/label_svc.dart';
import '../../shared/shared.dart';

class EditLabelsView extends StatefulWidget {
  const EditLabelsView({super.key});

  @override
  State<EditLabelsView> createState() => _EditLabelsViewState();
}

class _EditLabelsViewState extends State<EditLabelsView> {
  List<LabelModel> labels = [LabelModel(label: "")];
  LabelService labelService = LabelService.instance;
  late AuthBloc authBloc;
  late String uid;

  final List<FocusNode> focusNodes = [FocusNode()];
  final List<TextEditingController> textFieldContrs = [TextEditingController()];

  void insertLabel(FocusNode focusNode, TextEditingController textFieldContr) {
    final labelText = textFieldContr.text;
    if (textFieldContr.text.isNotEmpty) {
      labels.insert(1, LabelModel(label: labelText));
      focusNodes.insert(1, FocusNode());
      textFieldContrs.insert(1, TextEditingController(text: labelText));
      textFieldContr.clear();
    }
    focusNode.unfocus();
    setState(() {});
  }

  void deleteLabel(int index) {
    focusNodes[index].unfocus();
    labels.removeAt(index);
    focusNodes.removeAt(index);
    textFieldContrs.removeAt(index);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    uid = (authBloc.state as AuthStateAuthenticated).uid;
    initLabels();
  }

  Future<void> saveLabels() async {
    for (var i = 1; i < labels.length; i++) {
      labels[i].label = textFieldContrs[i].text;
    }
    labels.removeWhere((label) =>
        label.label.isEmpty ||
        // ======= not check same label && have diffence label String
        labels.any((l) => l != label && l.label == label.label));

    labelService.updateLabels(uid, labels);
  }

  Future<void> initLabels() async {
    final currentLabels = await labelService.getCurrentLabels(uid);
    labels.addAll(currentLabels);

    focusNodes
        .addAll(List.generate(currentLabels.length, (index) => FocusNode()));
    textFieldContrs.addAll(List.generate(
      currentLabels.length,
      (index) => TextEditingController(text: currentLabels[index].label),
    ));
    setState(() {});
  }

  @override
  void dispose() {
    saveLabels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit labels"),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final focusNode = focusNodes[index];
            final textFieldContr = textFieldContrs[index];
            if (index == 0) {
              return _LabelListTitle(
                leadingWidget: IconButton(
                  onPressed: () {
                    focusNode.requestFocus();
                  },
                  icon: Icon(
                    Icons.add,
                    color: ColorName.white,
                  ),
                ),
                focusLeadingWidget: IconButton(
                  onPressed: () {
                    focusNode.unfocus();
                    textFieldContr.clear();
                  },
                  icon: Icon(Icons.close),
                ),
                trailingWidget: SizedBox(),
                focusTrailingWidget: IconButton(
                  onPressed: () {
                    focusNode.unfocus();
                    if (index == 0) {
                      insertLabel(focusNode, textFieldContr);
                    }
                  },
                  icon: Icon(Icons.check),
                ),
                textEditingController: textFieldContrs[index],
                isAdd: true,
                focusNode: focusNodes[index],
              );
            }
            return _LabelListTitle(
              leadingWidget: IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.label_outline,
                  color: ColorName.white,
                ),
              ),
              focusLeadingWidget: IconButton(
                onPressed: () {
                  deleteLabel(index);
                },
                icon: Icon(Icons.delete_outline),
              ),
              trailingWidget: IconButton(
                onPressed: () {
                  focusNodes[index].requestFocus();
                },
                icon: Icon(Icons.edit),
              ),
              focusTrailingWidget: IconButton(
                onPressed: () {
                  focusNodes[index].unfocus();
                },
                icon: Icon(Icons.check),
              ),
              textEditingController: textFieldContrs[index],
              isAdd: false,
              focusNode: focusNodes[index],
            );
          },
          itemCount: labels.length,
        ),
      ),
    );
  }
}

class _LabelListTitle extends StatefulWidget {
  final Widget leadingWidget;
  final Widget focusLeadingWidget;
  final Widget trailingWidget;
  final Widget focusTrailingWidget;
  final TextEditingController textEditingController;
  final bool isAdd;
  final FocusNode focusNode;

  _LabelListTitle({
    required this.leadingWidget,
    required this.focusLeadingWidget,
    required this.trailingWidget,
    required this.focusTrailingWidget,
    required this.textEditingController,
    required this.isAdd,
    required this.focusNode,
  });
  @override
  State<_LabelListTitle> createState() => _LabelListTitleState();
}

class _LabelListTitleState extends State<_LabelListTitle> {
  bool _isFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: _isFocus
              ? BorderSide(color: ColorName.white, width: 1.0)
              : BorderSide.none,
          bottom: _isFocus
              ? BorderSide(color: ColorName.white, width: 1.0)
              : BorderSide.none,
        ),
      ),
      child: ListTile(
        leading: _isFocus
            ? widget.focusLeadingWidget
            : widget.isAdd
                // Wrap InkWell for avoid trigger leadingWidget when unfocus()
                ? InkWell(
                    child: widget.leadingWidget,
                  )
                : widget.leadingWidget,
        contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.normal),
        trailing: _isFocus
            ? widget.focusTrailingWidget
            : InkWell(child: widget.trailingWidget),
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        minLeadingWidth: 40,
        title: TextField(
          focusNode: widget.focusNode,
          controller: widget.textEditingController,
          decoration: InputDecoration(
            hintText: widget.isAdd ? 'Enter your text here' : '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
