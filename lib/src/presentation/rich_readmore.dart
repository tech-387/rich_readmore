library rich_readmore;

import 'package:flutter/material.dart';
import 'package:rich_readmore/src/core/helpers/text_span_helper.dart';
import 'package:rich_readmore/src/data/models/settings.dart';
import 'package:rich_readmore/src/presentation/rich_readmore_controller.dart';

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
  ///      trimCollapsedText: 'Expand',
  ///      trimExpandedText: ' Collapse ',
  ///    ),
  ///   controller: RichReadMoreController(
  ///     onPressReadMore: () {
  ///       //specific method to be called on press to show more
  ///     },
  ///     onPressReadLess: () {
  ///       // specific method to be called on press to show less
  ///     },
  ///   ),
  ///  ),
  /// ```

  const RichReadMoreText(
    this.data, {
    Key? key,
    required this.settings,
    this.controller,
    this.enableInteractionWhenCollapsed = false,
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
  ///      trimCollapsedText: '...Show more',
  ///      trimExpandedText: ' Show less',
  ///      lessStyle: TextStyle(color: Colors.blue),
  ///      moreStyle: TextStyle(color: Colors.blue),
  ///    ),
  ///   enableInteractionWhenCollapsed: true, // Allows interaction even when the text is collapsed
  ///  ),
  /// ```
  RichReadMoreText.fromString({
    Key? key,
    required String text,
    this.controller,
    TextStyle? textStyle,
    required this.settings,
    this.enableInteractionWhenCollapsed = false,
  }) : data = TextSpan(text: text, style: textStyle);

  /// The settings to control the trimming behavior.
  /// Can accept two different types, [LineModeSettings] or [LengthModeSettings]
  /// * Use [LineModeSettings] for trimming with a specific line number
  /// * Use [LengthModeSettings] for trimming with a specific character length
  final ReadMoreSettings settings;

  ///  The text to be displayed
  final TextSpan data;

  /// The controller for expanding or collapsing your text programatically.
  /// You can also register [onPressReadMore] and [onPressReadLess] callbacks.
  final RichReadMoreController? controller;

  /// When set to true, this allows for user interaction with the text even when it is collapsed.
  /// This is useful for maintaining engagement with elements like links embedded in the text, which
  /// might otherwise be disabled when the text is not fully expanded. Defaults to false to maintain
  /// traditional behavior where interaction is only possible when text is expanded.
  final bool enableInteractionWhenCollapsed;

  @override
  _RichReadMoreTextState createState() => _RichReadMoreTextState();
}

class _RichReadMoreTextState extends State<RichReadMoreText> {
  /// The alignment for the text
  ///
  /// Is set to `TextAlign.start` if the [settings.textAlign] is null
  late final TextAlign textAlign;

  /// The string for say if the actions is expand or collapse
  late TextSpan actionText;

  /// The helper class that contains the methods for managing the textSpans
  late final TextSpanHelper textSpanHelper;

  late final RichReadMoreController controller;

  /// A getter for the [TextScaler] to be used for the text.
  /// If the [settings.textScaler] is null, it will use the
  /// `MediaQuery.textScalerOf(context)`.
  TextScaler get textScaler =>
      widget.settings.textScaler ?? MediaQuery.textScalerOf(context);

  @override
  void initState() {
    super.initState();
    textAlign = widget.settings.textAlign ?? TextAlign.start;
    textSpanHelper = TextSpanHelper();
    controller = widget.controller ?? RichReadMoreController();
    actionText = textSpanHelper.updateActionText(
      isExpanded: controller.isExpanded,
      onTap: controller.onTapLink,
      settings: widget.settings,
    );
  }

  void updateActionText() {
    actionText = textSpanHelper.updateActionText(
      isExpanded: controller.isExpanded,
      onTap: controller.onTapLink,
      settings: widget.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        updateActionText();
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
                  textDirection:
                      widget.settings.textDirection ?? TextDirection.rtl,
                  textScaler: textScaler,
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

                int endIndex;

                bool isExpandable = false;

                if (widget.settings is LengthModeSettings) {
                  int trimLength =
                      (widget.settings as LengthModeSettings).trimLength;
                  endIndex = trimLength - 1;
                  isExpandable = widget.data.toPlainText().length > trimLength;
                } else if (actionTextSize.width < maxWidth) {
                  final readMoreSize = actionTextSize.width;
                  final pos = textPainter.getPositionForOffset(Offset(
                    widget.settings.textDirection == TextDirection.rtl
                        ? readMoreSize
                        : textSize.width - readMoreSize,
                    textSize.height,
                  ));
                  endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
                  isExpandable = textPainter.didExceedMaxLines;
                } else {
                  var pos = textPainter.getPositionForOffset(
                    textSize.bottomLeft(Offset.zero),
                  );
                  endIndex = pos.offset;
                }

                var textSpan = textSpanHelper.getTextSpanForTrimMode(
                  data: widget.data,
                  settings: widget.settings,
                  isExpanded: controller.isExpanded,
                  actionText: actionText,
                  didExceedMaxLines: textPainter.didExceedMaxLines,
                  endIndex: endIndex,
                );

                return IgnorePointer(
                  ignoring:
                      !widget.enableInteractionWhenCollapsed && !isExpandable,
                  child: Text.rich(
                    textSpan,
                    textAlign: textAlign,
                    textDirection: widget.settings.textDirection,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    textScaler: textScaler,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
