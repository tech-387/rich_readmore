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
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
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

  /// Can accept two different types of objects, [LineModeSettings] or [LengthModeSettings]
  /// * Use [LineModeSettings] for trimming with a specific line number
  /// * Use [LengthModeSettings] for trimming with a specific character length
  final ReadMoreSettings settings;

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

class ReadMoreTextState extends State<ReadMoreText> {
  bool _readMore = true;
  late final TextAlign textAlign;
  late final TextDirection textDirection;
  late final double textScaleFactor;
  late final Locale? locale;

  /// The string for say if the actions is expand or collapse
  late TextSpan actionText;

  @override
  void initState() {
    super.initState();
    textAlign = widget.textAlign ?? TextAlign.start;
    actionText = updateActionText(isExpanded: _readMore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textDirection = widget.textDirection ?? Directionality.of(context);
    textScaleFactor =
        widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    locale = widget.locale ?? Localizations.maybeLocaleOf(context);
  }

  TextSpan updateActionText({required bool isExpanded}) => TextSpan(
        text: isExpanded ? widget.trimCollapsedText : widget.trimExpandedText,
        style: isExpanded ? widget.moreStyle : widget.lessStyle,
        recognizer: TapGestureRecognizer()..onTap = _onTapLink,
      );

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    actionText = updateActionText(isExpanded: _readMore);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _readMore = !_readMore;
        });
      },
      child: Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              assert(constraints.hasBoundedWidth);
              final double maxWidth = constraints.maxWidth;

              // Layout and measure link
              TextPainter textPainter = TextPainter(
                text: actionText,
                textAlign: textAlign,
                textDirection: textDirection,
                textScaleFactor: textScaleFactor,
                maxLines: widget.settings is LineModeSettings
                    ? (widget.settings as LineModeSettings).trimLines
                    : null,
                locale: locale,
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
                final readMoreSize = actionTextSize.width * 1.5;
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
                  trimMode: widget.settings.trimMode,
                  // effectiveTextStyle: effectiveTextStyle,
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
          ),
        ),
      ),
    );
  }

  TextSpan _getTextSpanForTrimMode(
      {required TrimMode trimMode,
      // TextStyle? effectiveTextStyle,
      required TextSpan actionText,
      required TextPainter textPainter,
      required int endIndex,
      required bool actionTextLongerThanLine}) {
    switch (widget.settings.trimMode) {
      case TrimMode.length:
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
      case TrimMode.line:
        if (textPainter.didExceedMaxLines) {
          final textSpan =
              _readMore ? widget.data.substring(0, endIndex) : widget.data;
          return TextSpan(children: [textSpan, actionText]);
        } else {
          return TextSpan(children: [widget.data, actionText]);
        }
    }
  }
}
