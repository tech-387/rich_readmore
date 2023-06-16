import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_readmore/rich_readmore.dart';

import '../../mocks/rich_readmore_mocks.dart';

void main() {
  group('Using TextSpan', () {
    group('with LineModeSettings', () {
      final settings = LineModeSettings(
        trimLines: 3,
        colorClickableText: Colors.pink,
        trimCollapsedText: 'Expand',
        trimExpandedText: ' Collapse ',
      );

      Widget buildWidget(ReadMoreSettings settings) => MaterialApp(
            home: RichReadMoreText(RichReadMoreMocks.textSpan,
                settings: settings),
          );

      testWidgets('should displays correct text', (WidgetTester tester) async {
        final widget = buildWidget(settings);
        await tester.pumpWidget(widget);

        final textFinder = find.text('Don\'t have an account? Sign up');
        expect(textFinder, findsOneWidget);
      });
    });

    group('with LengthModeSettings', () {
      final settings = LengthModeSettings(
        trimLength: 10,
        colorClickableText: Colors.pink,
        trimCollapsedText: 'Expand',
        trimExpandedText: ' Collapse ',
      );

      Widget buildWidget(ReadMoreSettings settings) => MaterialApp(
            home: RichReadMoreText(RichReadMoreMocks.textSpan,
                settings: settings),
          );

      testWidgets(
          'should displays the expand action text when greater than the provided length for trimming',
          (WidgetTester tester) async {
        final widget = buildWidget(settings);
        await tester.pumpWidget(widget);

        final richText =
            find.byType(RichText).evaluate().single.widget as RichText;
        final plainText = richText.text.toPlainText();

        expect(plainText.contains(settings.trimCollapsedText), isTrue);
      });
    });
  });
}
