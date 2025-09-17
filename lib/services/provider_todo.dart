import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';

class ProviderTodo extends ChangeNotifier {
  List<String> _todos = [];

  ProviderTodo({List<String>? todos}) {
    String raw = localStorage.getItem('todos') ?? '[]';
    List<dynamic>? todos = [];
    try {
      todos = jsonDecode(raw);
    } catch (e) {
      if (kDebugMode) {
        print("Error decoding todos from local storage: $e");
      }
    }
    if (todos != null) {
      _todos = todos.map((e) => e.toString()).toList();
    }
  }

  List<String> get todos => _todos;

  void addTodo(String todo) {
    _todos.add(todo);
    localStorage.setItem('todos', jsonEncode(_todos));
    notifyListeners();
  }

  void removeTodoAt(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      localStorage.setItem('todos', jsonEncode(_todos));
      notifyListeners();
    }
  }
}
