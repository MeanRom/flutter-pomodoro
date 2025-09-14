import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TodoInput(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Task 1", style: TextStyle(fontSize: 16)),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                child: Icon(
                  LucideIcons.x,
                  color: CupertinoColors.systemRed,
                  size: 16,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TodoInput extends StatelessWidget {
  const TodoInput({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField.borderless(
      placeholder: "Add a new task",
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey)),
      ),
    );
  }
}
