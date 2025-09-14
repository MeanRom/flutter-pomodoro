import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/interface/i_todo.dart';

class Todo extends StatefulWidget {
  Todo({super.key});

  List<ITodo> todoslist = [];

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  @override
  void removeItem(ITodo todo) {
    setState(() {
      widget.todoslist.remove(todo);
    });
  }

  void addItem(String text) {
    setState(() {
      widget.todoslist.add(ITodo(text: text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TodoInput(onSubmit: addItem),
        Column(
          children: widget.todoslist
              .map((todo) => TodoItem(todo: todo, onRemove: removeItem))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class TodoInput extends StatelessWidget {
  TodoInput({super.key, required this.onSubmit});
  final Function(String) onSubmit;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField.borderless(
      controller: controller,
      placeholder: "Add a new task",
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey)),
      ),
      onSubmitted: (value) => {onSubmit(value), controller.clear()},
    );
  }
}

class TodoItem extends StatelessWidget {
  final ITodo todo;

  const TodoItem({super.key, required this.todo, required this.onRemove});
  final Function(ITodo) onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(todo.text, style: TextStyle(fontSize: 16)),
          CupertinoButton(
            mouseCursor: SystemMouseCursors.click,
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            child: Icon(
              LucideIcons.x,
              color: CupertinoColors.systemRed,
              size: 16,
            ),
            onPressed: () {
              onRemove(todo);
            },
          ),
        ],
      ),
    );
  }
}
