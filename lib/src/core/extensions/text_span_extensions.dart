import 'dart:math';

import 'package:flutter/material.dart';

extension TextSpanExtension on TextSpan {
  TextSpan copyWith(
      {String? text, TextStyle? style, List<TextSpan>? children}) {
    return TextSpan(
      text: text ?? this.text,
      style: style ?? this.style,
      children: children ?? this.children,
    );
  }

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

    return TextSpan(children: substringSpan, style: style);
  }
}
