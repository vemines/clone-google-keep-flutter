part of '../note_view.dart';

class _TodoSection extends StatefulWidget {
  const _TodoSection(this.todos, this.provider);
  final List<TodoModel> todos;
  final NoteProvider provider;

  @override
  State<_TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<_TodoSection> {
  late List<TodoModel> checkedTodo;
  late List<TodoModel> uncheckedTodo;
  @override
  void initState() {
    super.initState();
    checkedTodo = widget.todos.where((todo) => todo.checked == true).toList();
    uncheckedTodo =
        widget.todos.where((todo) => todo.checked == false).toList();
  }

  void addTodo() {
    uncheckedTodo.add(TodoModel(checked: false, text: ""));
    setState(() {});
  }

  void addCheckedTodo(TodoModel todo) {
    uncheckedTodo.remove(todo);
    todo.checked = true;
    checkedTodo.add(todo);
    setState(() {});
  }

  void removeCheckedTodo(TodoModel todo) {
    checkedTodo.remove(todo);
    todo.checked = false;
    uncheckedTodo.add(todo);
    setState(() {});
  }

  void removeTodo(bool isCheck, TodoModel todo) {
    isCheck ? checkedTodo.remove(todo) : uncheckedTodo.remove(todo);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.setTodos([...uncheckedTodo, ...checkedTodo]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            for (int i = 0; i < uncheckedTodo.length; i++)
              _TodoItem(
                key: UniqueKey(),
                todo: uncheckedTodo[i],
                index: i,
                onChecked: () => addCheckedTodo(uncheckedTodo[i]),
                onUnchecked: () => removeCheckedTodo(uncheckedTodo[i]),
                onRemove: () => removeTodo(false, uncheckedTodo[i]),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = uncheckedTodo.removeAt(oldIndex);
              uncheckedTodo.insert(newIndex, item);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: Dimensions.normal * 2),
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text("List item", style: context.textTheme.bodyLarge),
            onTap: addTodo,
          ),
        ),
        if (checkedTodo.length > 0)
          ExpansionTile(
            initiallyExpanded: true,
            shape: Border.all(width: 0),
            title: Text(
              "${checkedTodo.length} Checked items",
              style: context.textTheme.titleMedium,
            ),
            children: checkedTodo
                .map(
                  (todo) => _TodoItem(
                    key: UniqueKey(),
                    todo: todo,
                    index: null,
                    onChecked: () => addCheckedTodo(todo),
                    onUnchecked: () => removeCheckedTodo(todo),
                    onRemove: () => removeTodo(true, todo),
                  ),
                )
                .toList(),
          )
      ],
    );
  }
}

class _TodoItem extends StatefulWidget {
  const _TodoItem({
    required Key key,
    required this.todo,
    required this.onChecked,
    required this.onUnchecked,
    required this.onRemove,
    this.index,
  }) : super(key: key);
  final TodoModel todo;
  final Function() onChecked;
  final Function() onUnchecked;
  final Function() onRemove;
  final int? index;

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> {
  bool _isFocus = false;
  final FocusNode focusNode = FocusNode();
  late TextEditingController textEditController;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
    textEditController = TextEditingController(text: widget.todo.text);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    textEditController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: widget.todo.checked ? 0 : 1,
          child: widget.index == null
              ? Icon(Icons.drag_indicator_outlined)
              : ReorderableDragStartListener(
                  index: widget.index!,
                  child: const Icon(Icons.drag_indicator_outlined),
                ),
        ),
        Flexible(
          child: CheckboxListTile(
            value: widget.todo.checked,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: context.theme.hintColor,
            onChanged: (value) {
              if (value != null) {
                value ? widget.onChecked() : widget.onUnchecked();
              }
            },
            title: TextField(
              focusNode: focusNode,
              controller: textEditController,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: _isFocus
                    ? IconButton(
                        onPressed: widget.onRemove,
                        icon: Icon(Icons.close),
                      )
                    : null,
              ),
              onChanged: (value) {
                widget.todo.text = value;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}
