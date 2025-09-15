import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ProviderTodo extends ChangeNotifier {
  List<String> _todos = [];

  ProviderTodo({List<String>? todos}) {
    if (todos != null) _todos = todos;
  }

  List<String> get todos => _todos;

  void addTodo(String todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodoAt(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      notifyListeners();
    }
  }
}
