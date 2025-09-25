import 'package:flutter/material.dart';
import 'package:unst/res/unst_colors.dart';
import 'package:unst/widgets/unst_text_input.dart';

import 'dart:math' as math;
import 'package:flutter/rendering.dart';

// The main application widget.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: DynamicSizedLayoutExample(),
            ),
          ),
        ),
      ),
    );
  }
}

// A stateful widget to manage the text editing controller and focus.
class DynamicSizedLayoutExample extends StatefulWidget {
  const DynamicSizedLayoutExample({super.key});

  @override
  State<DynamicSizedLayoutExample> createState() =>
      _DynamicSizedLayoutExampleState();
}

class _DynamicSizedLayoutExampleState extends State<DynamicSizedLayoutExample> {
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(border: Border.all()),
      child: DynamicSizedLayout(
        children: <Widget>[
          TextFieldTapRegion(
            onTapOutside: (_) => focusNode.unfocus(),
            child: EditableText(
              controller: textEditingController,
              focusNode: focusNode,
              autofocus: false,
              maxLines: null,
              style: TextStyle(color: Colors.black, height: 1.4),
              cursorColor: Colors.black,
              backgroundCursorColor: Colors.black,
            ),
          ),
          // The icon button is the second child.
          Container(
            color: Colors.black,
            child: IconButton(
              onPressed: () {
                print("on buttton press");
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicSizedLayout extends MultiChildRenderObjectWidget {
  const DynamicSizedLayout({super.key, required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDynamicSizedLayout();
  }
}

class _RenderDynamicSizedLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData> {
  _RenderDynamicSizedLayout();

  late RenderBox _textField;
  late RenderBox _sendButton;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  void performLayout() {
    _textField = firstChild!;
    _sendButton = lastChild!;

    // Layout the send button first so we know its width.
    _sendButton.layout(constraints, parentUsesSize: true);

    // Text field gets the remaining width.
    final textConstraints = constraints.deflate(
      EdgeInsets.only(right: _sendButton.size.width),
    );
    _textField.layout(textConstraints, parentUsesSize: true);

    final height = math.max(_textField.size.height, _sendButton.size.height);

    size = Size(constraints.maxWidth, height);

    // Position children
    final textParentData = _textField.parentData as MultiChildLayoutParentData;
    textParentData.offset = Offset(0, (height - _textField.size.height) / 2);

    final buttonParentData =
        _sendButton.parentData as MultiChildLayoutParentData;
    buttonParentData.offset = Offset(
      constraints.maxWidth - _sendButton.size.width,
      (height - _sendButton.size.height),
    );

  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var textParentData = _textField.parentData as MultiChildLayoutParentData;
    var buttonParentData = _sendButton.parentData as MultiChildLayoutParentData;

    context.paintChild(_textField, offset + textParentData.offset);
    context.paintChild(_sendButton, offset + buttonParentData.offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final children = [firstChild, lastChild];
    for (final child in children.reversed) {
      final parentData = child?.parentData as MultiChildLayoutParentData;
      final childOffset = parentData.offset;

      final isHit = result.addWithPaintOffset(
        offset: childOffset,
        position: position,
        hitTest: (result, transformed) {
          return child?.hitTest(result, position: transformed) ?? false;
        },
      );

      if (isHit) return true;
    }
    return false;
  }
}
