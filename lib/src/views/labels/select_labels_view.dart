import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/label_model.dart';
import '../../data/services/label_svc.dart';
import '../../shared/shared.dart';

class SelectLabelsView extends StatefulWidget {
  const SelectLabelsView({super.key, required this.labelSelectedIds});
  final List<String> labelSelectedIds;

  @override
  State<SelectLabelsView> createState() => _SelectLabelsViewState();
}

class _SelectLabelsViewState extends State<SelectLabelsView> {
  List<LabelModel> labels = [];
  LabelService labelService = LabelService.instance;
  late AuthBloc authBloc;
  late String uid;

  List<bool> selected = [];

  void selectLabel(int index, bool value) {
    selected[index] = value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    uid = (authBloc.state as AuthStateAuthenticated).uid;
    initLabels();
  }

  Future<void> onExit() async {
    List<LabelModel> result = [];
    for (var i = 0; i < labels.length; i++) {
      if (selected[i]) {
        result.add(labels[i]);
      }
    }
    context.pop(result);
  }

  Future<void> initLabels() async {
    final currentLabels = await labelService.getCurrentLabels(uid);
    labels.addAll(currentLabels);
    selected.addAll(
      List.generate(
        currentLabels.length,
        (index) => widget.labelSelectedIds.contains(labels[index].id),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit labels"),
          leading: IconButton(
            onPressed: onExit,
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return _LabelListTitle(
              label: labels[index].label,
              onChanged: (value) => selectLabel(index, value ?? false),
              value: selected[index],
            );
          },
          itemCount: labels.length,
        ),
      ),
    );
  }
}

class _LabelListTitle extends StatelessWidget {
  final String label;
  final Function(bool?) onChanged;
  final bool value;

  _LabelListTitle({
    required this.label,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.normal),
      title: Row(
        children: [
          Icon(Icons.label_outline),
          SizedBox(width: Dimensions.normal),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}
