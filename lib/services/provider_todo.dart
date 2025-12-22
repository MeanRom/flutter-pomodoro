import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/models/todo_item.dart';
import 'package:pomodoro/models/todo_group.dart';

class ProviderTodo extends ChangeNotifier {
  List<TodoItem> _todos = [];
  List<TodoGroup> _groups = [];
  String? _selectedGroupId;

  ProviderTodo() {
    _loadFromStorage();
  }

  List<TodoItem> get todos {
    if (_selectedGroupId == null) {
      return _todos;
    }
    return _todos.where((todo) => todo.groupId == _selectedGroupId).toList();
  }

  List<TodoItem> get allTodos => _todos;

  List<TodoGroup> get groups => _groups;

  String? get selectedGroupId => _selectedGroupId;

  TodoGroup? get selectedGroup {
    if (_selectedGroupId == null) return null;
    try {
      return _groups.firstWhere((g) => g.id == _selectedGroupId);
    } catch (e) {
      return null;
    }
  }

  void _loadFromStorage() {
    // Load groups
    try {
      String groupsRaw = localStorage.getItem('todo_groups') ?? '[]';
      List<dynamic> groupsJson = jsonDecode(groupsRaw);
      _groups = groupsJson.map((json) => TodoGroup.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading groups: $e");
      }
      _groups = _getDefaultGroups();
    }

    // Ensure default group exists
    if (_groups.isEmpty) {
      _groups = _getDefaultGroups();
      _saveGroups();
    }
    _ensureDefaultGroup();

    // Load todos (migrate from old format if needed)
    try {
      String todosRaw = localStorage.getItem('todos') ?? '[]';
      dynamic todosData = jsonDecode(todosRaw);

      if (todosData is List) {
        if (todosData.isEmpty) {
          _todos = [];
        } else if (todosData.first is String) {
          // Migrate from old format (list of strings)
          _todos = todosData.map((title) => TodoItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + title.hashCode.toString(),
            title: title.toString(),
            groupId: 'default',
          )).toList();
          _saveTodos(); // Save in new format
        } else {
          // New format (list of objects)
          _todos = todosData.map((json) => TodoItem.fromJson(json)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading todos: $e");
      }
      _todos = [];
    }
  }

  List<TodoGroup> _getDefaultGroups() {
    return [
      TodoGroup(
        id: 'default',
        name: 'General',
        color: CupertinoColors.systemBlue,
        order: 0,
      ),
      TodoGroup(
        id: 'work',
        name: 'Work',
        color: CupertinoColors.systemRed,
        order: 1,
      ),
      TodoGroup(
        id: 'personal',
        name: 'Personal',
        color: CupertinoColors.systemGreen,
        order: 2,
      ),
    ];
  }

  void _ensureDefaultGroup() {
    final defaultIndex = _groups.indexWhere((g) => g.id == 'default');
    if (defaultIndex == -1) {
      _groups.insert(
        0,
        TodoGroup(
          id: 'default',
          name: 'General',
          color: CupertinoColors.systemBlue,
          order: 0,
        ),
      );
      _saveGroups();
    } else if (_groups[defaultIndex].name != 'General') {
      _groups[defaultIndex] = _groups[defaultIndex].copyWith(name: 'General');
      _saveGroups();
    }
    _selectedGroupId = 'default';
  }

  void _saveTodos() {
    final todosJson = _todos.map((todo) => todo.toJson()).toList();
    localStorage.setItem('todos', jsonEncode(todosJson));
  }

  void _saveGroups() {
    final groupsJson = _groups.map((group) => group.toJson()).toList();
    localStorage.setItem('todo_groups', jsonEncode(groupsJson));
  }

  void addTodo(String title, {String? groupId}) {
    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      groupId: groupId ?? _selectedGroupId ?? 'default',
    );
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void removeTodoAt(int index) {
    final filteredTodos = todos;
    if (index >= 0 && index < filteredTodos.length) {
      final todoToRemove = filteredTodos[index];
      _todos.removeWhere((t) => t.id == todoToRemove.id);
      _saveTodos();
      notifyListeners();
    }
  }

  void toggleTodoComplete(String todoId) {
    final todoIndex = _todos.indexWhere((t) => t.id == todoId);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void selectGroup(String? groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  void addGroup(String name, Color color) {
    final group = TodoGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      order: _groups.length,
    );
    _groups.add(group);
    _saveGroups();
    notifyListeners();
  }

  void updateGroup(String id, {String? name, Color? color}) {
    final groupIndex = _groups.indexWhere((g) => g.id == id);
    if (groupIndex != -1) {
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        name: name,
        color: color,
      );
      _saveGroups();
      notifyListeners();
    }
  }

  void removeGroup(String id) {
    if (id == 'default') return; // Can't delete default group

    // Move todos from this group to default
    for (var i = 0; i < _todos.length; i++) {
      if (_todos[i].groupId == id) {
        _todos[i] = _todos[i].copyWith(groupId: 'default');
      }
    }

    _groups.removeWhere((g) => g.id == id);
    if (_selectedGroupId == id) {
      _selectedGroupId = 'default';
    }

    _saveTodos();
    _saveGroups();
    notifyListeners();
  }

  void resetTodos() {
    _todos = [];
    localStorage.removeItem('todos');
    notifyListeners();
  }

  void resetGroups() {
    _groups = _getDefaultGroups();
    _selectedGroupId = 'default';
    _saveGroups();
    notifyListeners();
  }
}
