import 'package:flutter/material.dart';
               

class UnstTextInput extends StatelessWidget {
  final VoidCallback? onIconPressed;
  final IconData icon;
  final TextStyle? textStyle;
  final Color cursorColor;
  final Color iconButtonColor;
  final Color ? iconColor;
  final EdgeInsetsGeometry padding;
  final int? maxLines;
  final FocusNode? focusNode;
  const UnstTextInput({
    super.key,
    required this.controller,
    this.onIconPressed,
    this.icon = Icons.upgrade,
    this.textStyle,
    this.cursorColor = Colors.black,
    this.iconButtonColor = Colors.black,
    this.iconColor,
    this.padding = const EdgeInsets.all(12.0),
    this.maxLines,
    this.focusNode,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(color: Colors.black);

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: padding,
            child: SizedBox(
              width: double.infinity,
              child: EditableText(
                controller: controller,
                focusNode: focusNode ?? FocusNode(),
                cursorWidth: 8,
                style: textStyle ?? defaultTextStyle,
                cursorColor: cursorColor,
                backgroundCursorColor: cursorColor,
                maxLines: maxLines,
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            onPressed: onIconPressed ?? () {},
            visualDensity: VisualDensity.compact,
            icon: Icon(icon),
            style: IconButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: iconButtonColor,
              foregroundColor: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
