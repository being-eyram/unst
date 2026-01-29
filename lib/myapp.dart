import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:svg_flutter/svg.dart';
import 'package:flutter/rendering.dart';
import 'package:unst/res/unst_assets.dart';
import 'package:unst/res/unst_colors.dart';
import 'package:unst/services/gemini_services.dart';
import 'package:unst/widgets/app_logo.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  int selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _loading = false;
  List<Uint8List> _images = [];
  String? _lastPrompt;

  @override
  void dispose() {
    _focusNode.unfocus();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateImages() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _loading = true;
      _images = [];
      _lastPrompt = prompt;
    });

    final geminiService = Provider.of<GeminiService>(context, listen: false);
    final images = await geminiService.generateImages(prompt);

    setState(() {
      _images = images;
      _loading = false;
    });

    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        backgroundColor: UnstColors.appBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const AppLogo(),
                const SizedBox(height: 32),

                // show last prompt if available
                if (_lastPrompt != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _lastPrompt!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                // show loading spinner
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),

                // show generated images
                if (_images.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _images
                          .map((img) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    img,
                                    width: 140,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                const Spacer(),

                // input area
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(5, 5))
                    ],
                  ),
                  child: DynamicSizedLayout(
                    children: <Widget>[
                      TextField(
                        onTapOutside: (_) => _focusNode.unfocus(),
                        controller: _controller,
                        focusNode: _focusNode,
                        cursorWidth: 8,
                        cursorHeight: 24,
                        autofocus: false,
                        maxLines: null,
                        decoration: const InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: GoogleFonts.ibmPlexMono(
                          textStyle: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        cursorColor: Colors.black,
                        keyboardAppearance: Brightness.dark,
                      ),
                      Container(
                        color: Colors.black,
                        child: IconButton(
                          onPressed: _loading ? null : _generateImages,
                          icon: SvgPicture.asset(
                            UnstAssets.icSendBold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide()),
          ),
          child: NavigationBar(
            animationDuration: const Duration(milliseconds: 150),
            backgroundColor: UnstColors.bottomNavBackground,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            height: 96,
            indicatorColor: Colors.white,
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

class DynamicSizedLayout extends MultiChildRenderObjectWidget {
  const DynamicSizedLayout({super.key, required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderDynamicSizedLayout();
  }
}

class _RenderDynamicSizedLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
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

    final buttonConstraints =  BoxConstraints.tight(Size(56, 56));
    _sendButton.layout(buttonConstraints, parentUsesSize: true);

    final textConstraints = constraints.deflate(
      EdgeInsets.only(right: _sendButton.size.width),
    );
    _textField.layout(textConstraints, parentUsesSize: true);

    final height = math.max(_textField.size.height, _sendButton.size.height);
    size = Size(constraints.maxWidth, height);

    final textParentData = _textField.parentData as MultiChildLayoutParentData;
    textParentData.offset = Offset(0, (height - _textField.size.height) / 2);

    final buttonParentData =
        _sendButton.parentData as MultiChildLayoutParentData;
    buttonParentData.offset = Offset(
      constraints.maxWidth - _sendButton.size.width,
      (height - _sendButton.size.height) / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final textParentData = _textField.parentData as MultiChildLayoutParentData;
    final buttonParentData =
        _sendButton.parentData as MultiChildLayoutParentData;

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
