import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/models/todo_group.dart';
import 'package:pomodoro/services/provider_todo.dart';
import 'package:provider/provider.dart';

class GroupManager extends StatefulWidget {
  const GroupManager({super.key});

  @override
  State<GroupManager> createState() => _GroupManagerState();
}

class _GroupManagerState extends State<GroupManager> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = CupertinoColors.systemBlue;

    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => CupertinoAlertDialog(
          title: const Text('Create New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Group name',
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Choose color:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemGreen,
                  CupertinoColors.systemRed,
                  CupertinoColors.systemOrange,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                  CupertinoColors.systemTeal,
                  CupertinoColors.systemIndigo,
                ].map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? CupertinoColors.black
                                : CupertinoColors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(
                                LucideIcons.check,
                                color: CupertinoColors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    )).toList(),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<ProviderTodo>(context, listen: false)
                      .addGroup(nameController.text.trim(), selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, TodoGroup group) {
    final TextEditingController nameController =
        TextEditingController(text: group.name);
    Color selectedColor = group.color;

    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => CupertinoAlertDialog(
          title: const Text('Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Group name',
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Choose color:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemGreen,
                  CupertinoColors.systemRed,
                  CupertinoColors.systemOrange,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                  CupertinoColors.systemTeal,
                  CupertinoColors.systemIndigo,
                ].map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? CupertinoColors.black
                                : CupertinoColors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(
                                LucideIcons.check,
                                color: CupertinoColors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    )).toList(),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<ProviderTodo>(context, listen: false).updateGroup(
                    group.id,
                    name: nameController.text.trim(),
                    color: selectedColor,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TodoGroup group) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete "${group.name}"?'),
        content: const Text(
          'All tasks in this group will be moved to "General".',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Provider.of<ProviderTodo>(context, listen: false)
                  .removeGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderTodo>(
      builder: (context, provider, child) {
        final filteredGroups = provider.groups
            .where((group) =>
                group.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Manage Groups'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(LucideIcons.plus),
              onPressed: () => _showCreateGroupDialog(context),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Search groups',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Groups list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      final taskCount = provider.allTodos
                          .where((todo) => todo.groupId == group.id)
                          .length;

                      return CupertinoListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: group.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(group.name),
                        subtitle: Text('$taskCount tasks'),
                        trailing: group.id != 'default'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    child: const Icon(
                                      LucideIcons.pencil,
                                      size: 20,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                    onPressed: () =>
                                        _showEditGroupDialog(context, group),
                                  ),
                                  const SizedBox(width: 16),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    child: const Icon(
                                      LucideIcons.trash,
                                      size: 20,
                                      color: CupertinoColors.systemRed,
                                    ),
                                    onPressed: () =>
                                        _showDeleteConfirmation(context, group),
                                  ),
                                ],
                              )
                            : null,
                        onTap: () {
                          provider.selectGroup(group.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
