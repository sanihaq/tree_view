import 'package:flutter/material.dart';

class TreeTheme {
  /// text theme for name of the node
  final TextStyle textTheme;

  /// background color of currently selected node
  final Color selectColor;

  /// highlight any node from outside of tree area (by passing "shadowKey" in [TreeView])
  final Color shadowColor;

  /// background color of node when hovered
  final Color hoverColor;

  final Color treeLineColor;

  /// padding factor all nodes and its children
  final double leftPadding;

  /// padding value for top and bottom
  final double verticalPadding;

  final InputBorder inputBorder;

  TreeTheme({
    required this.textTheme,
    required this.selectColor,
    required this.shadowColor,
    required this.hoverColor,
    required this.treeLineColor,
    this.leftPadding = 8,
    this.verticalPadding = 4,
    this.inputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 1.0),
    ),
  });
}
