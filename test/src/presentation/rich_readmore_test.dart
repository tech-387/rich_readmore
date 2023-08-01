import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_readmore/rich_readmore.dart';

import '../../mocks/rich_readmore_mocks.dart';

void main() {
  Widget buildWidget(ReadMoreSettings settings) => MaterialApp(
        home: RichReadMoreText(RichReadMoreMocks.textSpan, settings: settings),
      );
  group('with LineModeSettings', () {
    final settings = LineModeSettings(
      trimLines: 3,
      trimCollapsedText: 'Expand',
      trimExpandedText: ' Collapse ',
    );

    testWidgets('should displays correct text', (WidgetTester tester) async {
      final widget = buildWidget(settings);
      await tester.pumpWidget(widget);

      final textFinder = find.text('Don\'t have an account? Sign up');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('should displays correct text from string',
        (WidgetTester tester) async {
      final widget = MaterialApp(
        home: RichReadMoreText.fromString(
            text: 'Don\'t have an account? Sign up', settings: settings),
      );
      await tester.pumpWidget(widget);

      final textFinder = find.text('Don\'t have an account? Sign up');
      expect(textFinder, findsOneWidget);
    });

    testWidgets('should ', (WidgetTester tester) async {
      final widget = buildWidget(LineModeSettings(
        trimLines: 3,
        trimCollapsedText:
            'Just a COLLAPSED test with a really long action text with characters enough to wrap line and does not have space enough being the action text greater than the max width!',
        trimExpandedText:
            'Just a EXPANDED test with a really long action text with characters enough to wrap line and does not have space enough being the action text greater than the max width!',
      ));
      await tester.pumpWidget(widget);

      final textFinder = find.text('Don\'t have an account? Sign up');
      expect(textFinder, findsOneWidget);
    });
  });

  group('with LengthModeSettings', () {
    final settings = LengthModeSettings(
      trimLength: 10,
      trimCollapsedText: 'Expand',
      trimExpandedText: ' Collapse ',
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

  group('common tests', () {
    final settings = LengthModeSettings(
      trimLength: 10,
      trimCollapsedText: 'Expand',
      trimExpandedText: ' Collapse ',
    );
    testWidgets('should update the action text after pressed',
        (WidgetTester tester) async {
      final widget = buildWidget(settings);
      await tester.pumpWidget(widget);

      RichText richText = tester.widget<RichText>(find.byType(RichText));

      richText.text.visitChildren(
        (visitor) {
          if (visitor is TextSpan &&
              visitor.text?.trim() == settings.trimCollapsedText.trim()) {
            (visitor.recognizer as TapGestureRecognizer).onTap?.call();

            return false;
          }
          return true;
        },
      );

      await tester.pumpAndSettle();
      RichText updatedRichText =
          find.byType(RichText).evaluate().single.widget as RichText;
      String plainText = updatedRichText.text.toPlainText();

      expect(plainText.contains(settings.trimExpandedText), isTrue);
      richText = tester.widget<RichText>(find.byType(RichText));

      richText.text.visitChildren(
        (visitor) {
          if (visitor is TextSpan &&
              visitor.text?.trim() == settings.trimExpandedText.trim()) {
            (visitor.recognizer as TapGestureRecognizer).onTap?.call();

            return false;
          }
          return true;
        },
      );

      await tester.pumpAndSettle();
      updatedRichText =
          find.byType(RichText).evaluate().single.widget as RichText;
      plainText = updatedRichText.text.toPlainText();

      expect(plainText.contains(settings.trimCollapsedText), isTrue);
    });
  });
}
