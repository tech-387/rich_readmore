library readmore;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:readmore/core/extensions/text_span_extensions.dart';
import 'package:readmore/data/models/settings.dart';
import 'package:readmore/data/models/trim_modes.dart';

class ReadMoreText extends StatefulWidget {
  const ReadMoreText(
    this.data, {
    Key? key,
    required this.settings,
  }) : super(key: key);

  /// Receives the [data] as String instead of RichText directly
  ReadMoreText.fromString({
    Key? key,
    required String text,
    required this.settings,
  }) : data = TextSpan(text: text);

  /// Can accept two different types of objects, [LineModeSettings] or [LengthModeSettings]
  /// * Use [LineModeSettings] for trimming with a specific line number
  /// * Use [LengthModeSettings] for trimming with a specific character length
  final ReadMoreSettings settings;

  final TextSpan data;

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

class ReadMoreTextState extends State<ReadMoreText> {
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
        text: isExpanded
            ? widget.settings.trimCollapsedText
            : widget.settings.trimExpandedText,
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
