import 'package:flutter/material.dart';
import 'package:rich_readmore/src/data/models/trim_modes.dart';

abstract class ReadMoreSettings {
  final TrimMode trimMode;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  /// Callback to be called on press to read more
  final VoidCallback? onPressReadMore;

  /// Callback to be called on press to read less
  final VoidCallback? onPressReadLess;

  ReadMoreSettings({
    required this.trimMode,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.onPressReadMore,
    this.onPressReadLess,
  });
}

class LineModeSettings extends ReadMoreSettings {
  final int trimLines;

  /// Settings for trim using line numbers
  LineModeSettings(
      {required this.trimLines,
      super.trimExpandedText,
      super.trimCollapsedText,
      super.colorClickableText,
      super.textAlign,
      super.textDirection,
      super.locale,
      super.textScaleFactor,
      super.semanticsLabel,
      super.moreStyle,
      super.lessStyle,
      super.onPressReadMore,
      super.onPressReadLess})
      : super(trimMode: TrimMode.line);
}

class LengthModeSettings extends ReadMoreSettings {
  final int trimLength;

  /// Settings form trim using characters length
  LengthModeSettings(
      {required this.trimLength,
      super.trimExpandedText,
      super.trimCollapsedText,
      super.colorClickableText,
      super.textAlign,
      super.textDirection,
      super.locale,
      super.textScaleFactor,
      super.semanticsLabel,
      super.moreStyle,
      super.lessStyle,
      super.onPressReadMore,
      super.onPressReadLess})
      : super(trimMode: TrimMode.length);
}
