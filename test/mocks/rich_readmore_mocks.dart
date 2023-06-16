import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RichReadMoreMocks {
  static final textSpan = TextSpan(
      text: 'Don\'t have an account?',
      style: TextStyle(color: Colors.black, fontSize: 18),
      children: <TextSpan>[
        TextSpan(
            text: ' Sign up',
            style: TextStyle(color: Colors.blueAccent, fontSize: 18),
            recognizer: TapGestureRecognizer()..onTap = () {}),
      ]);
}
