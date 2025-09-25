import 'package:flutter/material.dart';
import 'package:unst/res/unst_colors.dart';

enum _LayoutId { input_field, icon_button }

class UnstTextInput extends StatelessWidget {
  const UnstTextInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.black);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: EditableText(
                controller: controller,
                focusNode: FocusNode(),
                cursorWidth: 8,
                style: textStyle,
                cursorColor: Colors.black,
                backgroundCursorColor: Colors.black,
                maxLines: null,
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            onPressed: () => {},
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.upgrade),
            style: IconButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnstInputLayoutDelegate extends MultiChildLayoutDelegate {
  final TextEditingController controller;
  final TextStyle textStyle;

  _UnstInputLayoutDelegate({required this.controller, required this.textStyle});

  @override
  void performLayout(Size size) {
    final iconButtonSize = layoutChild(
      _LayoutId.icon_button,
      BoxConstraints(maxHeight: size.height, maxWidth: size.width),
    );

    final textHeight = _calculateTextHeight(
      controller.text,
      textStyle,
      size.width - iconButtonSize.width,
    );

    // Clamp between min and max
    final constrainedHeight = textHeight.clamp(88.0, 200.0);

    final inputFieldSize = layoutChild(
      _LayoutId.input_field,
      BoxConstraints(
        maxHeight: constrainedHeight,
        minHeight: constrainedHeight,
        maxWidth: size.width - iconButtonSize.width,
      ),
    );

    // Calculate actual line count using TextPainter
    final hasMultipleLines =
        _calculateLineCount(
          controller.text,
          textStyle,
          size.width - iconButtonSize.width,
        ) >
        1;

    // Input field positioning
    final inputFieldY = hasMultipleLines
        ? 0.0 // Top alignment for multiple lines
        : (iconButtonSize.height - inputFieldSize.height) / 2.0;

    // Icon button positioning
    final iconButtonY = hasMultipleLines
        ? inputFieldSize.height -
              iconButtonSize
                  .height // Bottom alignment
        : (iconButtonSize.height - inputFieldSize.height) /
              2.0; // Center alignment

    positionChild(_LayoutId.input_field, Offset(0, inputFieldY));
    positionChild(
      _LayoutId.icon_button,
      Offset(inputFieldSize.width, iconButtonY),
    );
  }

  int _calculateLineCount(String text, TextStyle style, double maxWidth) {
    if (text.isEmpty) return 1;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: maxWidth);

    return textPainter.computeLineMetrics().length;
  }

  double _calculateTextHeight(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text.isEmpty ? " " : text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }

  @override
  bool shouldRelayout(covariant _UnstInputLayoutDelegate oldDelegate) {
    return controller.text != oldDelegate.controller.text ||
        textStyle != oldDelegate.textStyle;
  }
}
