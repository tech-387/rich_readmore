import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_readmore/rich_readmore.dart';
import 'package:rich_readmore/src/core/helpers/text_span_helper.dart';

void main() {
  late final TextSpanHelper textSpanHelper;
  late final TextSpan textSpan;
  late final TextSpan actionText;
  late final LineModeSettings lineModeSettings;
  late final LengthModeSettings lengthModeSettings;

  setUpAll(() {
    textSpanHelper = TextSpanHelper();
    lineModeSettings = LineModeSettings(trimLines: 2);
    lengthModeSettings = LengthModeSettings(trimLength: 15);
    textSpan = TextSpan(
        text: 'Don\'t have an account? Contrary to popular belief, Lor',
        style: TextStyle(color: Colors.black, fontSize: 18),
        children: <TextSpan>[
          TextSpan(
            text: 'em Ipsum is not simply random text. ',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          TextSpan(
            text:
                'It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old',
          ),
        ]);
    actionText = textSpanHelper.updateActionText(
        settings: lineModeSettings, isExpanded: true, onTap: () {});
  });

  group('buildTextSpan method', () {
    test('should return a TextSpan containing the right span and actionText',
        () {
      final result =
          textSpanHelper.buildTextSpan(span: textSpan, actionText: actionText);
      final plainText = result.toPlainText();
      expect(plainText, contains(textSpan.toPlainText()));
      expect(plainText, contains(actionText.toPlainText()));
    });
  });

  group('getTextSpanForTrimMode method', () {
    group('for length trim mode', () {
      test(
          'should return a valid TextSpan when the text is greater than the trim length',
          () {
        final result = textSpanHelper.getTextSpanForTrimMode(
          data: textSpan,
          settings: lengthModeSettings,
          isExpanded: true,
          actionText: actionText,
          didExceedMaxLines: false,
          endIndex: (lengthModeSettings.trimLength),
        );

        final resultPlainText = result.toPlainText();
        final actionPlainText = actionText.toPlainText();
        expect(resultPlainText, isNot(contains(textSpan.toPlainText())));
        expect(resultPlainText.length,
            (lengthModeSettings.trimLength + actionPlainText.length));
      });

      test(
          'should return a valid TextSpan when the text is smaller or equals than the trim length',
          () {
        final shortTextSpan =
            TextSpan(text: 'just', children: [TextSpan(text: 'example')]);
        final result = textSpanHelper.getTextSpanForTrimMode(
          data: shortTextSpan,
          settings: lengthModeSettings,
          isExpanded: true,
          actionText: actionText,
          didExceedMaxLines: false,
          endIndex: (lengthModeSettings.trimLength - 1),
        );

        final resultPlainText = result.toPlainText();
        final shortPlainText = shortTextSpan.toPlainText();
        expect(resultPlainText, equals(shortPlainText));
        expect(resultPlainText.length, equals(shortPlainText.length));
      });
    });

    group('for line trim mode', () {
      test('should return a valid TextSpan when the text did exceed max lines',
          () {
        // In a real case, it will be defined using the TextPainter offset
        final int endIndex = 20;
        final result = textSpanHelper.getTextSpanForTrimMode(
            data: textSpan,
            settings: lineModeSettings,
            isExpanded: true,
            actionText: actionText,
            didExceedMaxLines: true,
            endIndex: endIndex);

        final resultPlainText = result.toPlainText();
        final actionPlainText = actionText.toPlainText();
        expect(resultPlainText, isNot(contains(textSpan.toPlainText())));
        expect(resultPlainText.length, (endIndex + actionPlainText.length));
      });

      test(
          'should return a valid TextSpan when the text did NOT exceed max line',
          () {
        final shortTextSpan =
            TextSpan(text: 'just', children: [TextSpan(text: 'example')]);
        // In a real case, it will be defined using the TextPainter offset
        final int endIndex = 20;
        final result = textSpanHelper.getTextSpanForTrimMode(
            data: shortTextSpan,
            settings: lineModeSettings,
            isExpanded: true,
            actionText: actionText,
            didExceedMaxLines: false,
            endIndex: endIndex);

        final resultPlainText = result.toPlainText();
        final shortPlainText = shortTextSpan.toPlainText();

        expect(resultPlainText, equals(shortPlainText));
        expect(resultPlainText.length, equals(shortPlainText.length));
      });
    });
  });

  group('updateActionText method', () {
    test('should return the right action text span when is expanded', () {
      final result = textSpanHelper.updateActionText(
          settings: lineModeSettings, isExpanded: true, onTap: () {});
      final plainText = result.toPlainText();
      expect(plainText, equals(' ${lineModeSettings.trimCollapsedText}'));
    });

    test('should return the right action text span when is collapsed', () {
      final result = textSpanHelper.updateActionText(
          settings: lineModeSettings, isExpanded: false, onTap: () {});
      final plainText = result.toPlainText();
      expect(plainText, equals(' ${lineModeSettings.trimExpandedText}'));
    });
  });
}
