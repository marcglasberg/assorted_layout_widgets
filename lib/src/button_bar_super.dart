import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:material_ui/material_ui.dart';

/// A replacement for [OverflowBar] (and the deprecated `ButtonBar`), that
/// distributes its buttons by using a [WrapSuper].
///
/// While [OverflowBar] lays out its children in a row, or in a column if they
/// don't fit, [ButtonBarSuper] wraps them in as many lines as needed, according
/// to the [wrapType] and [wrapFit].
///
/// The default is [WrapType.balanced] and [WrapFit.larger], which means it will
/// distribute the buttons in as little lines as possible in a balanced way;
/// will make the buttons fill all the available horizontal space; and will try
/// to make buttons have similar width in each line, without reducing their widths.
///
/// For more info, see: https://pub.dartlang.org/packages/assorted_layout_widgets
///
class ButtonBarSuper extends StatelessWidget {
  //
  /// The width of the gap between the buttons in the same line.
  ///
  /// Defaults to 0.0.
  final double spacing;

  /// The height of the gap between lines, when the buttons don't fit in a
  /// single line.
  ///
  /// Defaults to 0.0.
  final double overflowSpacing;

  /// The horizontal alignment of the buttons in each line.
  ///
  /// Defaults to [WrapSuperAlignment.left].
  final WrapSuperAlignment alignment;

  /// How the buttons are distributed into lines.
  ///
  /// Defaults to [WrapType.balanced].
  final WrapType wrapType;

  /// How the buttons are sized in each line.
  ///
  /// Defaults to [WrapFit.larger].
  final WrapFit wrapFit;

  /// The buttons to arrange horizontally.
  /// Typically [ElevatedButton] or [TextButton] widgets.
  final List<Widget> children;

  const ButtonBarSuper({
    super.key,
    this.spacing = 0.0,
    this.overflowSpacing = 0.0,
    this.alignment = WrapSuperAlignment.left,
    this.wrapType = WrapType.balanced,
    this.wrapFit = WrapFit.larger,
    this.children = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return WrapSuper(
      wrapType: wrapType,
      wrapFit: wrapFit,
      spacing: spacing,
      lineSpacing: overflowSpacing,
      alignment: alignment,
      children: children,
    );
  }
}
