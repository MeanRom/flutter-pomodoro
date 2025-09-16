import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/services/provider_todo.dart';
import 'package:provider/provider.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});
  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTodo>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.only(top: 77.0),
        child: Column(
          children: [
            CupertinoTextField.borderless(
              placeholder: 'Add a new task',
              controller: _controller,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  provider.addTodo(value.trim());
                  _controller.clear();
                }
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey4),
                ),
              ),
            ),
            for (var todo in provider.todos)
              TodoItem(
                todo: todo,
                index: provider.todos.indexOf(todo),
                onRemove: (index) {
                  provider.removeTodoAt(index);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final String todo;
  final int index;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onRemove,
    required this.index,
  });
  final Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(todo, style: TextStyle(fontSize: 16)),
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
              onRemove(index);
            },
          ),
        ],
      ),
    );
  }
}
