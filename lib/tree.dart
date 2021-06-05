import 'package:flutter/material.dart';
import 'package:tree_view/tree_controller.dart';
import 'package:tree_view/tree_theme.dart';

import 'node_model.dart';
import 'tree_node.dart';

/// Defines the [TreeView] widget.
///
/// This is the main widget for the package. It requires a controller
/// and allows you to specify other optional properties that manages
/// the appearance and handle events.
///
/// ```dart
/// TreeView(
///   controller: _treeViewController,
///   allowParentSelect: false,
///   supportParentDoubleTap: false,
///   onExpansionChanged: _expandNodeHandler,
///   onNodeTap: (key) {
///     setState(() {
///       _treeViewController = _treeViewController.copyWith(selectedKey: key);
///     });
///   },
///   theme: treeViewTheme
/// ),
/// ```
class TreeView extends InheritedWidget {
  /// The controller for the [TreeView]. It manages the data and selected key.
  final TreeViewController controller;

  final Widget Function(Node node, Widget child) wrap;

  /// The tap handler for a node. Passes the node key.
  final Function(Node) onNodeTap;

  final Function(Node, Offset) onNodeRightClick;

  /// The hover handler for a node. Passes the node key.
  final Function(Node)? onHover;

  final Icon Function(Node, double size) getIconForNode;

  final Widget? Function(Node, double size) getNotificationIconForNode;

  final Function(Node) onIconTap;

  /// The expand/collapse handler for a node. Passes the node key and the
  /// expansion state.
  final Function(Node, bool)? onExpansionChanged;

  /// The theme mode for [TreeView].
  final ThemeMode? themeMode;

  /// The theme for [TreeView].
  final TreeTheme theme;

  /// Determines whether the user can select a parent node. If false,
  /// tapping the parent will expand or collapse the node. If true, the node
  /// will be selected and the use has to use the expander to expand or
  /// collapse the node.
  final bool allowParentSelect;

  /// How the [TreeView] should respond to user input.
  final ScrollPhysics? physics;

  /// Whether the extent of the [TreeView] should be determined by the contents
  /// being viewed.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// Whether the [TreeView] is the primary scroll widget associated with the
  /// parent PrimaryScrollController..
  ///
  /// Defaults to true.
  final bool primary;

  /// Determines whether the parent node can receive a double tap. This is
  /// useful if [allowParentSelect] is true. This allows the user to double tap
  /// the parent node to expand or collapse the parent when [allowParentSelect]
  /// is true.
  /// ___IMPORTANT___
  /// _When true, the tap handler is delayed. This is because the double tap
  /// action requires a short delay to determine whether the user is attempting
  /// a single or double tap._
  final bool supportParentDoubleTap;

  // final IconData? icon;

  final List<Widget> Function(Node node)? buildActionsWidgets;

  final String? selectedKey;

  final String? shadowKey;

  final String? renameKey;

  final TextEditingController renameController;

  final bool isDragging;
  final void Function() onDragStart;
  final void Function() onDragEnd;
  final void Function(String start, Node end) onDragSuccess;
  final void Function(String start, Node end) onDragSuccessSecondary;

  TreeView({
    Key? key,
    required this.controller,
    required this.wrap,
    required this.onNodeTap,
    required this.onNodeRightClick,
    required this.theme,
    required this.renameController,
    required this.getIconForNode,
    required this.getNotificationIconForNode,
    required this.onIconTap,
    this.onHover,
    this.physics,
    this.onExpansionChanged,
    this.allowParentSelect: false,
    this.supportParentDoubleTap: false,
    this.shrinkWrap: false,
    this.primary: true,
    this.themeMode,
    // this.icon,
    this.buildActionsWidgets,
    this.selectedKey,
    this.shadowKey,
    this.renameKey,
    this.isDragging = false,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragSuccess,
    required this.onDragSuccessSecondary,
  }) : super(
          key: key,
          child: _TreeViewData(
            controller,
            shrinkWrap: shrinkWrap,
            primary: primary,
            physics: physics,
          ),
        );

  static TreeView? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType(aspect: TreeView);

  @override
  bool updateShouldNotify(TreeView oldWidget) {
    return oldWidget.controller.children != this.controller.children ||
        oldWidget.onNodeTap != this.onNodeTap ||
        oldWidget.onNodeRightClick != this.onNodeRightClick ||
        oldWidget.onHover != this.onHover ||
        oldWidget.renameController != this.renameController ||
        oldWidget.getIconForNode != this.getIconForNode ||
        oldWidget.getNotificationIconForNode !=
            this.getNotificationIconForNode ||
        oldWidget.onIconTap != this.onIconTap ||
        oldWidget.physics != this.physics ||
        oldWidget.onExpansionChanged != this.onExpansionChanged ||
        oldWidget.allowParentSelect != this.allowParentSelect ||
        oldWidget.supportParentDoubleTap != this.supportParentDoubleTap ||
        oldWidget.shrinkWrap != this.shrinkWrap ||
        oldWidget.primary != this.primary ||
        oldWidget.themeMode != this.themeMode ||
        oldWidget.theme != this.theme ||
        // oldWidget.icon != this.icon ||
        oldWidget.buildActionsWidgets != this.buildActionsWidgets ||
        oldWidget.selectedKey != this.selectedKey ||
        oldWidget.shadowKey != this.shadowKey ||
        oldWidget.renameKey != this.renameKey ||
        oldWidget.onDragStart != this.onDragStart ||
        oldWidget.onDragEnd != this.onDragEnd ||
        oldWidget.onDragSuccess != this.onDragSuccess ||
        oldWidget.onDragSuccessSecondary != this.onDragSuccessSecondary ||
        oldWidget.isDragging != this.isDragging;
  }
}

class _TreeViewData extends StatelessWidget {
  final TreeViewController _controller;
  final bool shrinkWrap;
  final bool primary;
  final ScrollPhysics? physics;

  const _TreeViewData(this._controller,
      {required this.shrinkWrap, required this.primary, this.physics});

  @override
  Widget build(BuildContext context) {
    ThemeData _parentTheme = Theme.of(context);
    return Theme(
      data: _parentTheme.copyWith(hoverColor: Colors.grey.shade100),
      child: ListView(
        shrinkWrap: shrinkWrap,
        primary: primary,
        physics: physics,
        padding: EdgeInsets.zero,
        children: _controller.children.map((Node node) {
          return TreeNode(node: node);
        }).toList(),
      ),
    );
  }
}
