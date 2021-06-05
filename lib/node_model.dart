import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:better_print/better_print.dart';

/// Defines the data used to display a [TreeNode].
///
/// Used by [TreeView] to display a [TreeNode].
///
/// This object allows the creation of key, name and type to display
/// a node on the [TreeView] widget. The key, name and type properties are
/// required. The key is needed for events that occur on the generated
/// [TreeNode]. It should always be unique.
class Node {
  /// The unique string that identifies this object.
  final String key;

  /// The string value that is displayed on the [TreeNode].
  final String name;

  /// type of [Node]. holds string representation of a enum value
  final String type;

  final String? inheritKey;

  /// The sub [Node]s of this object.
  final List<Node> children;

  /// The open or closed state of the [TreeNode]. Applicable only if the
  /// node is a parent
  final bool expanded;

  final int maxChildren;

  /// Name of the group this node belong to in parent children group. can be [null]
  final String? group;

  final bool isReplaceable;

  /// Generic data model that can be assigned to the [TreeNode]. This makes
  /// it useful to assign and retrieve data associated with the [TreeNode]
  final Map<String, dynamic>? data;

  Node({
    required this.key,
    required this.name,
    required this.type,
    this.inheritKey,
    this.group,
    this.isReplaceable = false,
    this.expanded: true,
    this.data = const {},
    this.children: const [],
    this.maxChildren = 0,
  });

  /// Creates a [Node] from a Map<String, dynamic> map. The map
  /// should contain a "key", "name" and "type" value.
  factory Node.fromMap(Map<String, dynamic> map) {
    String _key = map['key'];
    String _label = map['name'];
    String _type = map['type'];
    String? _inheritKey = map['inheritKey'];
    bool? _expanded = map['expanded'];
    var _maxChildren = map['maxChildren'];
    var _group = map['group'];
    bool? _isReplaceable = map['replaceable'];
    var _data = Map<String, dynamic>.from(map['data'] ?? {});
    List<Node> _children = [];
    if (map['children'] != null) {
      List<Map<String, dynamic>> _childrenMap = List.from(map['children']);
      _children = _childrenMap
          .map((Map<String, dynamic> child) => Node.fromMap(child))
          .toList();
    }
    final node = Node(
      key: _key,
      name: _label,
      type: _type,
      inheritKey: _inheritKey,
      children: _children,
      expanded: _expanded ?? true,
      group: _group,
      isReplaceable: _isReplaceable ?? false,
      data: _data,
      maxChildren: _maxChildren ?? 0,
    );
    return node;
  }

  /// Creates a copy of this object but with the given fields
  /// replaced with the new values.
  Node copyWith({
    String? key,
    String? name,
    String? type,
    String? inheritKey,
    String? group,
    bool? expanded,
    bool? isReplaceable,
    Map<String, dynamic>? data,
    List<Node>? children,
    int? maxChildren,
  }) =>
      Node(
        key: key ?? this.key,
        name: name ?? this.name,
        type: type ?? this.type,
        inheritKey: inheritKey ?? this.inheritKey,
        group: group ?? this.group,
        expanded: expanded ?? this.expanded,
        isReplaceable: isReplaceable ?? this.isReplaceable,
        maxChildren: maxChildren ?? this.maxChildren,
        data: data ?? this.data,
        children: children ?? this.children,
      );

  /// Whether this object has children [Node].
  bool get isParent => children.isNotEmpty;

  /// Whether this object has data associated with it.
  bool get hasData => data != null;

  /// Map representation of this object
  Map<String, dynamic> get asMap {
    Map<String, dynamic> _map = {
      "key": key,
      "name": name,
      "type": type,
      "inheritKey": inheritKey,
      "replaceable": isReplaceable,
      "group": group,
      "expanded": expanded,
      "maxChildren": maxChildren,
      "data": data,
      "children": children.map((Node child) => child.asMap).toList(),
    };
    return _map;
  }

  @override
  String toString() {
    return JsonEncoder().convert(asMap);
  }

  @override
  int get hashCode {
    return hashValues(
      key,
      name,
      type,
      group,
      expanded,
      inheritKey,
      isReplaceable,
      data,
      children,
      maxChildren,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Node &&
        other.key == key &&
        other.name == name &&
        other.type == type &&
        other.group == group &&
        other.inheritKey == inheritKey &&
        other.expanded == expanded &&
        other.isReplaceable == isReplaceable &&
        other.data.runtimeType == Map &&
        other.maxChildren == maxChildren &&
        other.children.length == children.length;
  }
}
