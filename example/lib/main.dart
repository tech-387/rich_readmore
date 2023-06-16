import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_readmore/rich_readmore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF02BB9F),
        primaryColorDark: const Color(0xFF167F67),
      ),
      title: 'Read More Text',
      home: DemoApp(),
    );
  }
}

final actionTextStyle =
    TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold);

class DemoApp extends StatelessWidget {
  final TextSpan textSpan = TextSpan(
      text: 'Don\'t have an account? Contrary to popular belief, Lor',
      style: TextStyle(
          color: Colors.blueGrey, fontSize: 18, fontWeight: FontWeight.bold),
      children: <TextSpan>[
        TextSpan(
          text: 'em Ipsum is not simply random text. ',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        TextSpan(
          text:
              'It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old',
        ),
        TextSpan(
            text: ' Sign up',
            style: TextStyle(color: Colors.black, fontSize: 18),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // navigate to desired screen
              }),
        TextSpan(
            text:
                ' Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old'),
        TextSpan(
            text: ' Just another link for know what will happens',
            style: TextStyle(color: Colors.black, fontSize: 18),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // navigate to desired screen
              }),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Rich Read More Text',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
      ),
      body: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 16.0,
          //fontFamily: 'monospace',
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  'Length Mode',
                  style: actionTextStyle,
                ),
              ),
              Padding(
                key: const Key('showMoreLength'),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichReadMoreText.fromString(
                  text:
                      'Flutter is Google’s mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase.',
                  textStyle: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  settings: LengthModeSettings(
                    trimLength: 50,
                    trimCollapsedText: '...Show more',
                    trimExpandedText: ' Show less',
                    lessStyle: actionTextStyle,
                    moreStyle: actionTextStyle,
                    onPressReadMore: () {
                      /// specific method to be called on press to show more
                    },
                    onPressReadLess: () {
                      /// specific method to be called on press to show less
                    },
                  ),
                ),
              ),
              Divider(
                color: const Color(0xFFB2B2B2),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  'Line Mode',
                  style: actionTextStyle,
                ),
              ),
              Padding(
                key: const Key('showMoreLine'),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichReadMoreText(
                  textSpan,
                  settings: LineModeSettings(
                    trimLines: 3,
                    trimCollapsedText: '...Expand',
                    trimExpandedText: ' Collapse ',
                    lessStyle: actionTextStyle.copyWith(fontSize: 18),
                    moreStyle: actionTextStyle.copyWith(fontSize: 18),
                    onPressReadMore: () {
                      /// specific method to be called on press to show more
                    },
                    onPressReadLess: () {
                      /// specific method to be called on press to show less
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
