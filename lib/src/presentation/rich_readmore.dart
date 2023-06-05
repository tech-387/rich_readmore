library rich_readmore;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_readmore/src/core/extensions/text_span_extensions.dart';
import 'package:rich_readmore/src/data/models/settings.dart';
import 'package:rich_readmore/src/data/models/trim_modes.dart';

class RichReadMoreText extends StatefulWidget {
  /// A widget that displays text with an option to show more or show less based on the provided settings.
  ///
  /// The `RichReadMoreText` widget allows you to trim text either based on the character length or the number of lines.
  /// When the text is longer than the specified trim length or exceeds the maximum number of lines, it provides a
  /// toggle option to show more or show less of the text.
  /// If you want to pass a [String] instead of TextSpan, take a look at the `RichReadMoreText.fromString()` constructor.
  ///
  /// Example usage:
  /// ```dart
  ///  RichReadMoreText(
  ///    textSpan,
  ///    settings: LineModeSettings(
  ///      trimLines: 3,
  ///      colorClickableText: Colors.pink,
  ///      trimCollapsedText: 'Expand',
  ///      trimExpandedText: ' Collapse ',
  ///    ),
  ///  ),
  /// ```
  const RichReadMoreText(
    this.data, {
    Key? key,
    required this.settings,
  }) : super(key: key);

  /// A widget that displays text with an option to show more or show less based on the provided settings.
  ///
  /// The `RichReadMoreText` widget allows you to trim text either based on the character length or the number of lines.
  /// When the text is longer than the specified trim length or exceeds the maximum number of lines, it provides a
  /// toggle option to show more or show less of the text.
  ///
  /// [text] is the text that will be displayed
  ///
  /// [textStyle] is the style for the [text]
  /// Example usage:
  /// ```dart
  ///  RichReadMoreText.fromString(
  ///    text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
  ///    textStyle: TextStyle(color: Colors.purpleAccent),
  ///    settings: LengthModeSettings(
  ///      trimLength: 20,
  ///      colorClickableText: Colors.pink,
  ///      trimCollapsedText: '...Show more',
  ///      trimExpandedText: ' Show less',
  ///      lessStyle: TextStyle(color: Colors.blue),
  ///      moreStyle: TextStyle(color: Colors.blue),
  ///    ),
  ///  ),
  /// ```
  RichReadMoreText.fromString({
    Key? key,
    required String text,
    TextStyle? textStyle,
    required this.settings,
  }) : data = TextSpan(text: text, style: textStyle);

  /// The settings to control the trimming behavior.
  /// Can accept two different types, [LineModeSettings] or [LengthModeSettings]
  /// * Use [LineModeSettings] for trimming with a specific line number
  /// * Use [LengthModeSettings] for trimming with a specific character length
  final ReadMoreSettings settings;

  ///  The text to be displayed
  final TextSpan data;

  @override
  RichReadMoreTextState createState() => RichReadMoreTextState();
}

class RichReadMoreTextState extends State<RichReadMoreText> {
  bool _readMore = true;
  late final TextAlign textAlign;

  /// The string for say if the actions is expand or collapse
  late TextSpan actionText;

  @override
  void initState() {
    super.initState();
    textAlign = widget.settings.textAlign ?? TextAlign.start;
    actionText = updateActionText(isExpanded: _readMore);
  }

  TextSpan updateActionText({required bool isExpanded}) => TextSpan(
        text: ' ' +
            (isExpanded
                ? widget.settings.trimCollapsedText
                : widget.settings.trimExpandedText),
        style:
            isExpanded ? widget.settings.moreStyle : widget.settings.lessStyle,
        recognizer: TapGestureRecognizer()..onTap = _onTapLink,
      );

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.settings.callback?.call(_readMore);
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    actionText = updateActionText(isExpanded: _readMore);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textDirection: widget.settings.textDirection,
      label: widget.settings.semanticsLabel,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            assert(constraints.hasBoundedWidth);
            final double maxWidth = constraints.maxWidth;

            // Layout and measure link
            TextPainter textPainter = TextPainter(
              text: actionText,
              textAlign: textAlign,
              textDirection: widget.settings.textDirection ?? TextDirection.rtl,
              textScaleFactor: widget.settings.textScaleFactor ?? 1.0,
              maxLines: widget.settings is LineModeSettings
                  ? (widget.settings as LineModeSettings).trimLines
                  : null,
              locale: widget.settings.locale,
            );
            textPainter.layout(minWidth: 0, maxWidth: maxWidth);
            final actionTextSize = textPainter.size;

            // Layout and measure text
            textPainter.text = widget.data;
            textPainter.layout(
                minWidth: constraints.minWidth, maxWidth: maxWidth);
            final textSize = textPainter.size;

            // Get the endIndex of data
            bool actionTextLongerThanLine = false;
            int endIndex;

            if (actionTextSize.width < maxWidth) {
              final readMoreSize = actionTextSize.width;
              final pos = textPainter.getPositionForOffset(Offset(
                widget.settings.textDirection == TextDirection.rtl
                    ? readMoreSize
                    : textSize.width - readMoreSize,
                textSize.height,
              ));
              endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
            } else {
              var pos = textPainter.getPositionForOffset(
                textSize.bottomLeft(Offset.zero),
              );
              endIndex = pos.offset;
              actionTextLongerThanLine = true;
            }

            var textSpan = _getTextSpanForTrimMode(
                trimMode: widget.settings.trimMode,
                // effectiveTextStyle: effectiveTextStyle,
                actionText: actionText,
                textPainter: textPainter,
                endIndex: endIndex,
                actionTextLongerThanLine: actionTextLongerThanLine);

            return Text.rich(
              textSpan,
              textAlign: textAlign,
              textDirection: widget.settings.textDirection,
              softWrap: true,
              overflow: TextOverflow.clip,
              textScaleFactor: widget.settings.textScaleFactor,
            );
          },
        ),
      ),
    );
  }

  /// Returns a [TextSpan] adding the [actionText] on the children
  TextSpan _buildTextSpan(TextSpan span) =>
      TextSpan(children: [span, actionText]);

  /// Returns a treated TextSpan depending on the [TrimMode] provided.
  TextSpan _getTextSpanForTrimMode(
      {required TrimMode trimMode,
      // TextStyle? effectiveTextStyle,
      required TextSpan actionText,
      required TextPainter textPainter,
      required int endIndex,
      required bool actionTextLongerThanLine}) {
    switch (widget.settings.trimMode) {
      case TrimMode.length:
        final LengthModeSettings lengthSettings =
            widget.settings as LengthModeSettings;
        if (lengthSettings.trimLength < widget.data.toPlainText().length) {
          final textSpan = _readMore
              ? widget.data.substring(0, lengthSettings.trimLength)
              : widget.data;
          return _buildTextSpan(textSpan);
        } else {
          return _buildTextSpan(widget.data);
        }
      case TrimMode.line:
        if (textPainter.didExceedMaxLines) {
          final textSpan =
              _readMore ? widget.data.substring(0, endIndex) : widget.data;
          return _buildTextSpan(textSpan);
        } else {
          return _buildTextSpan(widget.data);
        }
    }
  }
}
