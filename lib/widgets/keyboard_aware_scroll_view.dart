// lib/widgets/keyboard_aware_scroll_view.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A keyboard-aware scroll view that automatically adjusts its content
/// when the keyboard appears to prevent overlap with text fields and buttons.
class KeyboardAwareScrollView extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.reverse = false,
    this.controller,
    this.primary,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  State<KeyboardAwareScrollView> createState() => _KeyboardAwareScrollViewState();
}

class _KeyboardAwareScrollViewState extends State<KeyboardAwareScrollView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: widget.padding,
      physics: widget.physics,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      dragStartBehavior: widget.dragStartBehavior,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.top - 
                     MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: widget.child,
        ),
      ),
    );
  }
}

/// A keyboard-aware column that automatically adjusts its content
/// when the keyboard appears to prevent overlap with text fields and buttons.
class KeyboardAwareColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final EdgeInsetsGeometry? padding;

  const KeyboardAwareColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareScrollView(
      padding: padding,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: [
          ...children,
          // Add bottom padding to ensure content is above system navigation
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
