// ignore_for_file: avoid_implementing_value_types

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

/// [TextOneLineEllipsisWithFade] is a substitute for [Text] when [maxLines] is 1.
///
/// This widget only makes sense while that issue is not fixed:
/// https://github.com/flutter/flutter/issues/18761
///
/// It will use a special fade-with-ellipsis, which is
/// much better than the current buggy and ugly-looking ellipsis.
///
@Deprecated("This widget will be removed soon. Please use TextOneLine instead.")
class TextOneLineEllipsisWithFade extends StatelessWidget implements Text {
  @override
  final String data;

  @override
  TextSpan? get textSpan => null;

  @override
  final TextStyle? style;

  @override
  final StrutStyle? strutStyle;

  @override
  final TextAlign textAlign;

  @override
  final TextDirection? textDirection;

  @override
  final Locale? locale;

  @override
  bool get softWrap => false;

  @override
  final TextOverflow overflow;

  @override
  final double? textScaleFactor;

  @override
  int get maxLines => 1;

  @override
  final TextWidthBasis textWidthBasis;

  @override
  final TextHeightBehavior? textHeightBehavior;

  @override
  final Color? selectionColor;

  const TextOneLineEllipsisWithFade(
    this.data, {
    Key? key,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.locale,
    this.overflow = TextOverflow.ellipsis,
    this.textScaleFactor,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.selectionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextOneLine(
      data,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  @override
  String? get semanticsLabel => null;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
