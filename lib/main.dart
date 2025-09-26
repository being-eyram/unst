import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';
import 'package:unst/res/unst_assets.dart';
import 'package:unst/res/unst_colors.dart';
import 'package:unst/widgets/app_logo.dart';
import 'package:unst/widgets/unst_text_input.dart';

import 'dart:math' as math;
import 'package:flutter/rendering.dart';

// The main application widget.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: UnstColors.appBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                AppLogo(),

                SizedBox(height: 40,),

                Flexible(child: DynamicSizedLayoutExample()),
              ],
            ),
          ),
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide()),
          ),
          child: NavigationBar(
            animationDuration: Duration(milliseconds: 150),
            backgroundColor: UnstColors.bottomNavBackground,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            height: 96,
            indicatorColor: Colors.white,
            indicatorShape: Border.all(),

            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(
                selectedIcon: SvgPicture.asset(UnstAssets.icHomeBold),
                icon: SvgPicture.asset(UnstAssets.icHome),
                label: "",
              ),
              NavigationDestination(
                icon: SvgPicture.asset(UnstAssets.icWardrobe),
                selectedIcon: SvgPicture.asset(UnstAssets.icWardrobeBold),
                label: "",
              ),
            ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2),
        boxShadow: [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
      ),
      child: DynamicSizedLayout(
        children: <Widget>[
          TextField(
            onTapOutside: (_) => focusNode.unfocus(),
            controller: textEditingController,
            focusNode: focusNode,
            cursorWidth: 8,
            cursorHeight: 24,
            autofocus: false,
            maxLines: null,

            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: GoogleFonts.ibmPlexMono(
              textStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),

            cursorColor: Colors.black,
            keyboardAppearance: Brightness.dark,
          ),
          // The icon button is the second child.
          Container(
            color: Colors.black,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: Border.all(),
                  useSafeArea: true,
                  builder: (context) {
                    return Container(height: 400);
                  },
                );
              },
              icon: SvgPicture.asset(
                UnstAssets.icSendBold,
                color: Colors.white,
              ),
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

    final buttonConstraints = BoxConstraints.tight(Size(56, 56));
    // Layout the send button first so we know its width.
    _sendButton.layout(buttonConstraints, parentUsesSize: true);

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
