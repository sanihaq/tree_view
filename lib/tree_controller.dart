import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/widgets.dart';

import 'node_model.dart';

/// Defines the insertion mode adding a new [Node] to the [TreeView].
enum InsertMode { prepend, append, insert, replace, changeParent }

/// Defines the controller needed to display the [TreeView].
///
/// Used by [TreeView] to display the nodes and selected node.
///
/// This class also defines methods used to manipulate data in
/// the [TreeView]. The methods ([addNode], [updateNode],
/// and [deleteNode]) are non-mutilating, meaning they will not
/// modify the tree but instead they will return a mutilated
/// copy of the data. You can then use your own logic to appropriately
/// update the [TreeView]. e.g.
///
/// ```dart
/// TreeViewController controller = TreeViewController(children: nodes);
/// Node node = controller.getNode('unique_key');
/// Node updatedNode = node.copyWith(
///   key: 'another_unique_key',
///   label: 'Another Node',
/// );
/// List<Node> newChildren = controller.updateNode(node.key, updatedNode);
/// controller = TreeViewController(children: newChildren);
/// ```
class TreeViewController {
  /// The data for the [TreeView].
  final List<Node> children;

  /// The key of the select node in the [TreeView].
  final String? selectedKey;

  TreeViewController({
    this.children: const [],
    this.selectedKey,
  });

  /// Creates a copy of this controller but with the given fields
  /// replaced with the new values.
  TreeViewController copyWith({List<Node>? children, String? selectedKey}) {
    return TreeViewController(
      children: children ?? this.children,
      selectedKey: selectedKey ?? this.selectedKey,
    );
  }

  /// Loads this controller with data from a JSON String
  /// This method expects the user to properly update the state
  ///
  /// ```dart
  /// setState((){
  ///   controller = controller.loadJSON(json: jsonString);
  /// });
  /// ```
  TreeViewController loadJSON({
    required String json,
    required String selectKey,
  }) {
    List jsonList = jsonDecode(json);
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(jsonList);
    return loadMap(
      map: list,
      selectKey: selectKey,
    );
  }

  /// Loads this controller with data from a Map.
  /// This method expects the user to properly update the state
  ///
  /// ```dart
  /// setState((){
  ///   controller = controller.loadMap(map: dataMap);
  /// });
  /// ```
  TreeViewController loadMap({
    required List<Map<String, dynamic>> map,
    String? selectKey,
  }) {
    final List<Node> children =
        map.map((Map<String, dynamic> item) => Node.fromMap(item)).toList();
    return TreeViewController(
      children: children,
      selectedKey: selectKey ?? this.selectedKey,
    );
  }

  /// Gets the node that has a key value equal to the specified key.
  Node? getNode(String key, {Node? parent}) {
    Node? _found;
    List<Node> _children = parent == null ? this.children : parent.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Node child = iter.current;
      if (child.key == key) {
        _found = child;
        break;
      } else {
        if (child.isParent) {
          _found = this.getNode(key, parent: child);
          if (_found != null) {
            break;
          }
        }
      }
    }
    return _found;
  }

  /// Gets the parent of the node identified by specified key.
  Node? getParent(String key, {Node? parent}) {
    Node? _found;
    List<Node> _children = parent == null ? this.children : parent.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Node child = iter.current;
      if (child.key == key) {
        _found = parent ?? null; //? fix
        break;
      } else {
        if (child.isParent) {
          _found = this.getParent(key, parent: child);
          if (_found != null) {
            break;
          }
        }
      }
    }
    return _found;
  }

  /// Get all the ancestors of the node.
  List<Node> getAllChildren(Node node, [List<Node> _found = const []]) {
    List<Node> _found = [];
    List<Node> _children = node.children;
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Node child = iter.current;
      _found.add(child);
      _found.addAll(this.getAllChildren(child, _found));
    }
    return _found;
  }

  /// Adds a new node to an existing node identified by specified key. It optionally
  /// accepts an [InsertMode] and index. If no [InsertMode] is specified,
  /// it appends the new node as a child at the end. This method returns
  /// a new list with the added node.
  List<Node> addNode(
    String key,
    Node newNode, {
    Node? parent,
    InsertMode mode: InsertMode.append,
    int? index,
    String? group,
  }) {
    List<Node> _children = parent == null ? this.children : parent.children;
    return _children.map((Node child) {
      if (child.key == key) {
        List<Node> _children = child.children.toList(growable: true);
        if (mode == InsertMode.prepend) {
          _children.insert(index ?? 0, newNode);
        } else if (mode == InsertMode.append) {
          _children.insert(
              index != null ? index + 1 : _children.length, newNode);
        } else if (mode == InsertMode.replace) {
          final children = _addChildrenFrom(_children[index ?? 0].key);
          _children.removeAt(index ?? 0);
          _children.insert(index ?? 0, newNode.copyWith(children: children));
        } else if (mode == InsertMode.changeParent) {
          final _child = _children[index ?? 0];
          _children.removeAt(index ?? 0);
          _children.insert(
            index ?? 0,
            newNode.copyWith(
              children: [_child.copyWith(group: group ?? _child.group)],
            ),
          );
        } else {
          _children.add(newNode);
        }
        return child.copyWith(children: _children);
      } else {
        return child.copyWith(
          children: addNode(
            key,
            newNode,
            parent: child,
            mode: mode,
            index: index,
            group: group,
          ),
        );
      }
    }).toList();
  }

  List<Node> _addChildrenFrom(String key) {
    List<Node> _children = [];
    final children = getNode(key)?.children;
    children?.forEach((child) {
      _children.add(child.copyWith(
        children: deleteNode(key, parent: child),
      ));
    });
    return _children;
  }

  /// Updates an existing node identified by specified key. This method
  /// returns a new list with the updated node.
  List<Node> updateNode(String key, Node newNode, {Node? parent}) {
    List<Node> _children = parent == null ? this.children : parent.children;
    return _children.map((Node child) {
      if (child.key == key) {
        return newNode;
      } else {
        if (child.isParent) {
          return child.copyWith(
            children: updateNode(
              key,
              newNode,
              parent: child,
            ),
          );
        }
        return child;
      }
    }).toList();
  }

  /// Toggles an existing node identified by specified key. This method
  /// returns a new list with the specified node toggled.
  List<Node>? toggleNode(String key, {Node? parent}) {
    List<Node> _children = [];
    Node? _node = getNode(key, parent: parent);
    if (_node != null)
      _children = updateNode(key, _node.copyWith(expanded: !_node.expanded));

    return _children;
  }

  /// Deletes an existing node identified by specified key. This method
  /// returns a new list with the specified node removed.
  List<Node> deleteNode(
    String key, {
    Node? parent,
    bool deleteChildren = false,
    String? group,
  }) {
    List<Node> _children = parent == null ? this.children : parent.children;
    List<Node> _filteredChildren = [];
    Iterator iter = _children.iterator;
    while (iter.moveNext()) {
      Node child = iter.current;
      if (child.key != key) {
        if (child.isParent) {
          _filteredChildren.add(child.copyWith(
            children: deleteNode(key,
                parent: child, group: group, deleteChildren: deleteChildren),
          ));
        } else {
          _filteredChildren.add(child);
        }
      } else {
        if (!deleteChildren) {
          final children = getNode(key)?.children;
          children?.forEach((child) {
            _filteredChildren.add(child.copyWith(
              group: group ?? child.group,
              children: deleteNode(key,
                  parent: child, group: group, deleteChildren: deleteChildren),
            ));
          });
        }
      }
    }
    return _filteredChildren;
  }

  List<Node> reorderNode(String key, int arg, [isUp = true]) {
    final parent = getParent(key);
    final _children = parent?.children ?? this.children;
    final index = _children.indexWhere((element) => element.key == key);
    if (_children.isNotEmpty && index >= 0) {
      final n = _children.removeAt(index);
      if (isUp) {
        _children.insert(arg > 0 ? arg - 1 : arg, n);
      } else {
        _children.insert(_children.length == arg ? arg : arg + 1, n);
      }
    }
    return this.children;
  }

  /// Get the current selected node. Returns null if there is no selectedKey
  Node? get selectedNode {
    return this.selectedKey == null || this.selectedKey!.isEmpty
        ? null
        : getNode(this.selectedKey!);
  }

  /// Map representation of this object
  List<Map<String, dynamic>> get asMap {
    return children.map((Node child) => child.asMap).toList();
  }

  @override
  String toString() {
    return jsonEncode(asMap);
  }
}
