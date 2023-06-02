library readmore;

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum TrimMode {
  Length,
  Line,
}

class ReadMoreText extends StatefulWidget {
  const ReadMoreText(
    this.data, {
    Key? key,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.Length,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.callback,
    this.onLinkPressed,
    this.linkTextStyle,
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final ValueChanged<String>? onLinkPressed;

  final TextStyle? linkTextStyle;

  final TextSpan data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor =
        widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    // final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText =
        widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final _defaultLessStyle = widget.lessStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);
    final _defaultMoreStyle = widget.moreStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);

    /// The string for say if the actions is expand or collapse
    TextSpan actionText = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? _defaultMoreStyle : _defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: actionText,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          // ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final actionTextSize = textPainter.size;

        // //! Layout and measure delimiter
        // textPainter.text = _delimiter;
        // textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        // final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = widget.data;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool actionTextLongerThanLine = false;
        int endIndex;

        if (actionTextSize.width < maxWidth) {
          final readMoreSize = actionTextSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl
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
            trimMode: widget.trimMode,
            effectiveTextStyle: effectiveTextStyle,
            actionText: actionText,
            textPainter: textPainter,
            endIndex: endIndex,
            actionTextLongerThanLine: actionTextLongerThanLine);

        return Text.rich(
          textSpan,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.clip,
          textScaleFactor: textScaleFactor,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return GestureDetector(
      child: result,
      onTap: () {
        setState(() {
          _readMore = !_readMore;
        });
      },
    );
  }

  TextSpan _getTextSpanForTrimMode(
      {required TrimMode trimMode,
      TextStyle? effectiveTextStyle,
      required TextSpan actionText,
      required TextPainter textPainter,
      required int endIndex,
      required bool actionTextLongerThanLine}) {
    switch (widget.trimMode) {
      case TrimMode.Length:
      // if (widget.trimLength < widget.data.length) {
      //   return _buildData(
      //     data: _readMore
      //         ? widget.data.substring(0, widget.trimLength)
      //         : widget.data,
      //     textStyle: effectiveTextStyle,
      //     linkTextStyle: effectiveTextStyle?.copyWith(
      //       decoration: TextDecoration.underline,
      //       color: Colors.blue,
      //     ),
      //     onPressed: widget.onLinkPressed,
      //     children: [delimiter, link],
      //   );
      // } else {
      //   return _buildData(
      //     data: widget.data,
      //     textStyle: effectiveTextStyle,
      //     linkTextStyle: effectiveTextStyle?.copyWith(
      //       decoration: TextDecoration.underline,
      //       color: Colors.blue,
      //     ),
      //     onPressed: widget.onLinkPressed,
      //     children: [],
      //   );
      // }
      case TrimMode.Line:
        if (textPainter.didExceedMaxLines) {
          // return _buildData(
          //   data: _readMore
          //       ? widget.data.substring(0, endIndex) +
          //           (linkLongerThanLine ? _kLineSeparator : '')
          //       : widget.data,
          //   // textStyle: effectiveTextStyle,
          //   // children: [delimiter, link],
          // );

          return widget.data.substring(0, endIndex);
        } else {
          return widget.data;
        }
      default:
        throw Exception('TrimMode type: ${widget.trimMode} is not supported');
    }
  }
}

extension TextSpanExtension on TextSpan {
  TextSpan substring(int start, int end) {
    final substringSpan = <TextSpan>[];
    int lengthCount = 0;

    visitChildren((span) {
      if (lengthCount >= end + 1) return false;

      final missingCount = (end + 1) - lengthCount;
      if (span is TextSpan) {
        substringSpan.add(
          TextSpan(
            text: span.text!.substring(0, min(missingCount, span.text!.length)),
            style: span.style,
          ),
        );
        lengthCount += span.text!.length;
      }

      return true;
    });

    return TextSpan(children: substringSpan);
  }
}
