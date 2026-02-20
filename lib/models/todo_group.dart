import 'package:flutter/cupertino.dart';

class TodoGroup {
  final String id;
  final String name;
  final Color color;
  final int order;

  TodoGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.order,
  });

  factory TodoGroup.fromJson(Map<String, dynamic> json) {
    return TodoGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'order': order,
    };
  }

  TodoGroup copyWith({
    String? id,
    String? name,
    Color? color,
    int? order,
  }) {
    return TodoGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}
