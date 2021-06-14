import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'components/tree_hierarchy_lines.dart';
import 'tree.dart';
import 'node_model.dart';

class TreeNode extends StatefulWidget {
  TreeNode(
      {required this.node, this.nestFactor = 0, this.isLastChild = const []});
  final Node node;
  final int nestFactor;
  final List<bool> isLastChild; // pass array of args

  @override
  _TreeNodeState createState() => _TreeNodeState();
}

class _TreeNodeState extends State<TreeNode> {
  static const padLeft = 4.0;
  bool isOnHover = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView doesn\'t exist in context');
    if (_treeView != null && _treeView.renameKey == widget.node.key) {
      _treeView.renameController.text = widget.node.name;
      _treeView.renameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _treeView.renameController.value.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.isLastChild);
    TreeView? _treeView = TreeView.of(context);
    assert(_treeView != null, 'TreeView doesn\'t exist in context');
    return _treeView != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _treeView.wrap(
                widget.node,
                // tmp right click functionality remove after proper implementation on flutter side
                GestureDetector(
                  onSecondaryTapDown: (details) {
                    _treeView.onNodeRightClick(
                        widget.node, details.globalPosition);
                  },
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.basic,
                    onHover: (h) {
                      if (!_treeView.isDragging)
                        setState(() {
                          isOnHover = h;
                        });
                    },
                    onTap: () => _treeView.onNodeTap(widget.node),
                    // onDoubleTap: () {
                    //   _treeView.onEditName(widget.node);
                    // },
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            left:
                                _treeView.theme.leftPadding * widget.nestFactor,
                            top: _treeView.theme.verticalPadding,
                            bottom: _treeView.theme.verticalPadding,
                          ),
                          color: _treeView.selectedKey == widget.node.key
                              ? _treeView.theme.selectColor
                              : isOnHover ||
                                      _treeView.shadowKey == widget.node.key
                                  ? _treeView.theme.hoverColor
                                  : null,
                          child: Padding(
                            padding: const EdgeInsets.only(left: padLeft),
                            child: ClipRect(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _treeView.onIconTap(widget.node),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            if (widget.node.children.isNotEmpty)
                                              if (!widget.node.expanded)
                                                Icon(
                                                  Icons.keyboard_arrow_up,
                                                  size: _treeView
                                                      .theme.textTheme.fontSize,
                                                  color: _treeView
                                                      .theme.textTheme.color,
                                                )
                                              else
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: _treeView
                                                      .theme.textTheme.fontSize,
                                                  color: _treeView
                                                      .theme.textTheme.color,
                                                ),
                                            _treeView.getIconForNode(
                                                widget.node,
                                                _treeView.theme.textTheme
                                                        .fontSize ??
                                                    0)
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: ((_treeView.theme.textTheme
                                                        .fontSize ??
                                                    0) *
                                                0.6),
                                            left: (_treeView.theme.textTheme
                                                        .fontSize ??
                                                    0) *
                                                0.9 *
                                                (widget.node.children.isNotEmpty
                                                    ? 2
                                                    : 1),
                                          ),
                                          child: Builder(builder: (context) {
                                            return _treeView
                                                    .getNotificationIconForNode(
                                                        widget.node,
                                                        _treeView
                                                                .theme
                                                                .textTheme
                                                                .fontSize ??
                                                            0) ??
                                                SizedBox();
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  if (_treeView.renameKey == widget.node.key)
                                    Flexible(
                                      child: TextField(
                                        controller: _treeView.renameController,
                                        style: _treeView.theme.textTheme,
                                        onSubmitted: (name) {},
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          hintText: 'give it a name',
                                          hintStyle: _treeView.theme.textTheme
                                              .copyWith(
                                                  color: _treeView
                                                      .theme.textTheme.color
                                                      ?.withOpacity(0.3)),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 4.0),
                                          isDense: true,
                                          border: _treeView.theme.inputBorder,
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Draggable(
                                        data: widget.node.key,
                                        onDragStarted: () {
                                          setState(() {
                                            isOnHover = false;
                                          });
                                          _treeView.onDragStart();
                                        },
                                        onDragCompleted: _treeView.onDragEnd,
                                        onDraggableCanceled: (_, __) =>
                                            _treeView.onDragEnd(),
                                        feedback: Opacity(
                                          opacity: 0.6,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _treeView.theme.hoverColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(8)),
                                            ),
                                            padding: EdgeInsets.all(_treeView
                                                .theme.verticalPadding),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.copy,
                                                    color: _treeView
                                                        .theme.textTheme.color,
                                                    size: _treeView.theme
                                                        .textTheme.fontSize,
                                                  ),
                                                ),
                                                Text(
                                                  widget.node.name,
                                                  style:
                                                      _treeView.theme.textTheme,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        child: Text.rich(
                                          TextSpan(
                                            text: widget.node.name,
                                            children: [
                                              TextSpan(
                                                text:
                                                    ' ${widget.node.group == null ? 'root' : widget.node.group}',
                                                style: _treeView.theme.textTheme
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: _treeView
                                                      .theme.textTheme.color!
                                                      .withOpacity(0.4),
                                                  fontSize: (_treeView
                                                              .theme
                                                              .textTheme
                                                              .fontSize ??
                                                          16) -
                                                      2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          softWrap: false,
                                          overflow: TextOverflow.clip,
                                          style: _treeView.theme.textTheme,
                                        ),
                                      ),
                                    ),
                                  if (!_treeView.isDragging &&
                                      isOnHover &&
                                      _treeView.buildActionsWidgets != null &&
                                      _treeView.renameKey == null)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children:
                                              _treeView.buildActionsWidgets!(
                                                  widget.node),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_treeView.isDragging)
                          Container(
                            height: (_treeView.theme.verticalPadding * 3) +
                                (_treeView.theme.textTheme.fontSize ?? 0),
                            padding: EdgeInsets.only(
                              left: _treeView.theme.leftPadding *
                                  widget.nestFactor,
                            ),
                            color: Colors.transparent,
                            child: DragTarget(
                              onAccept: (String data) {
                                _treeView.onDragSuccessSecondary(
                                    data, widget.node);
                              },
                              builder: (BuildContext context,
                                  List<String?> candidateData,
                                  List<dynamic> rejectedData) {
                                return candidateData.isNotEmpty &&
                                        candidateData.first != widget.node.key
                                    ? Tooltip(
                                        message: 'move above',
                                        preferBelow: true,
                                        decoration: BoxDecoration(
                                          color: _treeView.theme.hoverColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        textStyle: _treeView.theme.textTheme,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                  color: _treeView
                                                      .theme.primaryColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                        if (_treeView.isDragging)
                          Container(
                            height: (_treeView.theme.verticalPadding * 3) +
                                (_treeView.theme.textTheme.fontSize ?? 0),
                            width: _treeView.theme.leftPadding *
                                (widget.nestFactor + 2),
                            color: Colors.transparent,
                            child: DragTarget(
                              onAccept: (String data) {
                                _treeView.onDragSuccess(data, widget.node);
                              },
                              builder: (BuildContext context,
                                  List<String?> candidateData,
                                  List<dynamic> rejectedData) {
                                return candidateData.isNotEmpty &&
                                        candidateData.first != widget.node.key
                                    ? Tooltip(
                                        message: 'add node',
                                        preferBelow: true,
                                        decoration: BoxDecoration(
                                          color: _treeView.theme.selectColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        textStyle: _treeView.theme.textTheme,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: _treeView
                                                      .theme.primaryColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.node.expanded)
                ...widget.node.children
                    .map((Node node) => Stack(
                          children: [
                            TreeNode(
                              node: node,
                              nestFactor: widget.nestFactor + 1,
                              isLastChild: [
                                ...widget.isLastChild,
                                (widget.node.children.length - 1 ==
                                    widget.node.children.indexOf(node)),
                              ],
                            ),
                            CustomPaint(
                              painter: HorizontalLinePainter(
                                width: _treeView.theme.leftPadding / 2,
                                height:
                                    (_treeView.theme.textTheme.fontSize ?? 16) -
                                        1,
                                color: _treeView.theme.treeLineColor,
                                padding: _treeView.theme.leftPadding,
                                nestFactor: widget.nestFactor,
                                pos: widget.node.children.indexOf(node),
                                lastPos: widget.node.children.length - 1,
                                isParentLast: widget.isLastChild,
                              ),
                            ),
                          ],
                        ))
                    .toList(),
            ],
          )
        : SizedBox();
  }
}
