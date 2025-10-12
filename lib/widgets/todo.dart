import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTodo>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Column(
          children: [
            CupertinoTextField.borderless(
              placeholder: 'Add a new task',
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  provider.addTodo(value.trim());
                  _controller.clear();
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              },
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey4),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 380,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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

  List<String> _splitTodoText(String text) {
    // Split on common delimiters like ':' and ';'
    final delimiters = RegExp(r'[:|;]');
    return text
        .split(delimiters)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  List<String> _getDelimiters(String text) {
    final delimiters = RegExp(r'[:|;]');
    return delimiters.allMatches(text).map((match) => match.group(0)!).toList();
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
  }

  List<Widget> _buildButtonsWithDelimiters(
    List<String> textParts,
    List<String> delimiters,
    BuildContext context,
  ) {
    List<Widget> widgets = [];

    for (int i = 0; i < textParts.length; i++) {
      // Add the clickable button for the text part
      widgets.add(
        CupertinoButton(
          mouseCursor: SystemMouseCursors.click,
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0),
          borderRadius: BorderRadius.circular(8.0),
          child: Text(
            textParts[i],
            style: TextStyle(color: CupertinoColors.label),
          ),
          onPressed: () {
            _copyToClipboard(textParts[i], context);
          },
        ),
      );

      // Add the non-clickable delimiter if not the last item
      if (i < delimiters.length) {
        widgets.add(Text(delimiters[i]));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final textParts = _splitTodoText(todo);
    final delimiters = _getDelimiters(todo);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: textParts.length > 1
                  ? Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: _buildButtonsWithDelimiters(
                        textParts,
                        delimiters,
                        context,
                      ),
                    )
                  : CupertinoButton(
                      mouseCursor: SystemMouseCursors.click,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      child: Text(
                        todo,
                        style: TextStyle(color: CupertinoColors.label),
                        softWrap: true,
                      ),
                      onPressed: () {
                        _copyToClipboard(todo, context);
                      },
                    ),
            ),
          ),
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
