import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/models/todo_item.dart';
import 'package:pomodoro/services/provider_todo.dart';
import 'package:pomodoro/widgets/group_manager_sheet.dart';
import 'package:provider/provider.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});
  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isGroupSelectorExpanded = true;

  void _showGroupManager(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const GroupManagerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTodo>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Column(
          children: [
            // Collapsible group selector section
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isGroupSelectorExpanded ? 40 : 0,
              child: _isGroupSelectorExpanded
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        // All tasks button
                        _GroupChip(
                          label: 'All',
                          count: provider.allTodos.length,
                          color: CupertinoColors.systemGrey,
                          isSelected: provider.selectedGroupId == null,
                          onTap: () => provider.selectGroup(null),
                        ),
                        const SizedBox(width: 8),
                        // Group chips with task count
                        ...provider.groups.map((group) {
                          final taskCount = provider.allTodos
                              .where((todo) => todo.groupId == group.id)
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _GroupChip(
                              label: group.name,
                              count: taskCount,
                              color: group.color,
                              isSelected: provider.selectedGroupId == group.id,
                              onTap: () => provider.selectGroup(group.id),
                            ),
                          );
                        }),
                        // Manage groups button
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          minSize: 0,
                          borderRadius: BorderRadius.circular(16),
                          color: CupertinoColors.systemGrey5,
                          onPressed: () => _showGroupManager(context),
                          child: const Icon(
                            LucideIcons.settings,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // Toggle button and group info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Expand/Collapse button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () {
                      setState(() {
                        _isGroupSelectorExpanded = !_isGroupSelectorExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isGroupSelectorExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isGroupSelectorExpanded
                              ? 'Hide Groups'
                              : provider.selectedGroup?.name ?? 'All Tasks',
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Task statistics
                  if (provider.todos.isNotEmpty)
                    Text(
                      '${provider.todos.where((t) => t.isCompleted).length}/${provider.todos.length} done',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                ],
              ),
            ),
            // Task input with group indicator
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField.borderless(
                    placeholder: provider.selectedGroup != null
                        ? 'Add task to ${provider.selectedGroup!.name}'
                        : 'Add a new task',
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
                        bottom: BorderSide(
                          color: provider.selectedGroup?.color
                                  .withOpacity(0.3) ??
                              CupertinoColors.systemGrey4,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                if (provider.selectedGroup != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.selectedGroup!.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Task list
            Expanded(
              child: provider.todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.selectedGroup != null
                                ? 'No tasks in ${provider.selectedGroup!.name}'
                                : 'No tasks yet',
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a task to get started!',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: provider.todos.length,
                      itemBuilder: (context, index) {
                        final todo = provider.todos[index];
                        return TodoItemWidget(
                          todoItem: todo,
                          index: index,
                          groupColor: provider.groups
                              .firstWhere((g) => g.id == todo.groupId,
                                  orElse: () => provider.groups.first)
                              .color,
                          onRemove: (idx) => provider.removeTodoAt(idx),
                          onToggleComplete: () =>
                              provider.toggleTodoComplete(todo.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minSize: 0,
      borderRadius: BorderRadius.circular(16),
      color: isSelected ? color : color.withOpacity(0.2),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? CupertinoColors.white : color,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.white.withOpacity(0.3)
                    : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? CupertinoColors.white : color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  final int index;
  final Color groupColor;
  final Function(int) onRemove;
  final VoidCallback onToggleComplete;

  const TodoItemWidget({
    super.key,
    required this.todoItem,
    required this.onRemove,
    required this.onToggleComplete,
    required this.index,
    required this.groupColor,
  });

  List<String> _splitTodoText(String text) {
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
      widgets.add(
        CupertinoButton(
          mouseCursor: SystemMouseCursors.click,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          borderRadius: BorderRadius.circular(8.0),
          child: Text(
            textParts[i],
            style: TextStyle(
              color: todoItem.isCompleted
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.label,
              decoration:
                  todoItem.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          onPressed: () {
            _copyToClipboard(textParts[i], context);
          },
        ),
      );

      if (i < delimiters.length) {
        widgets.add(Text(
          delimiters[i],
          style: TextStyle(
            color: todoItem.isCompleted
                ? CupertinoColors.systemGrey
                : CupertinoColors.label,
          ),
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final textParts = _splitTodoText(todoItem.title);
    final delimiters = _getDelimiters(todoItem.title);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: groupColor,
            width: 3,
          ),
        ),
        color: CupertinoColors.systemGrey6.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Checkbox
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: onToggleComplete,
            child: Icon(
              todoItem.isCompleted
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              size: 24,
              color: todoItem.isCompleted ? groupColor : groupColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 12),
          // Task text
          Expanded(
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
                    minimumSize: const Size(0, 0),
                    child: Text(
                      todoItem.title,
                      style: TextStyle(
                        color: todoItem.isCompleted
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.label,
                        decoration: todoItem.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      softWrap: true,
                    ),
                    onPressed: () {
                      _copyToClipboard(todoItem.title, context);
                    },
                  ),
          ),
          // Delete button
          CupertinoButton(
            mouseCursor: SystemMouseCursors.click,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            child: const Icon(
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
