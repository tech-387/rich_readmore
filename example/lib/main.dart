import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

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

class DemoApp extends StatelessWidget {
  final TextSpan textSpan = TextSpan(
      text: 'Don\'t have an account? Contrary to popular belief, Lor',
      style: TextStyle(color: Colors.black, fontSize: 18),
      children: <TextSpan>[
        TextSpan(
          text: 'em Ipsum is not simply random text. ',
          style: TextStyle(color: Colors.red),
        ),
        TextSpan(
            text:
                'It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old'),
        TextSpan(
            text: ' Sign up',
            style: TextStyle(color: Colors.blueAccent, fontSize: 18),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // navigate to desired screen
              }),
        TextSpan(
            text:
                ' Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old'),
        TextSpan(
            text: ' Just another link for know what will happens',
            style: TextStyle(color: Colors.blueAccent, fontSize: 18),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // navigate to desired screen
              }),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Read More Text',
        style: TextStyle(color: Colors.white),
      )),
      body: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 16.0,
          //fontFamily: 'monospace',
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Padding(
              //   key: const Key('showMore'),
              //   padding: const EdgeInsets.all(16.0),
              //   child: ReadMoreText(
              //     'Flutter is Google’s mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase.',
              //     trimLines: 2,
              //     preDataText: "AMANDA",
              //     preDataTextStyle: TextStyle(fontWeight: FontWeight.w500),
              //     style: TextStyle(color: Colors.black),
              //     colorClickableText: Colors.pink,
              //     trimMode: TrimMode.Line,
              //     trimCollapsedText: '...Show more',
              //     trimExpandedText: ' show less',
              //   ),
              // ),
              // Divider(
              //   color: const Color(0xFF167F67),
              // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReadMoreText(
                  textSpan,
                  trimLines: 3,
                  style: TextStyle(color: Colors.black),
                  colorClickableText: Colors.pink,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: '...Expand',
                  trimExpandedText: ' Collapse ',
                  onLinkPressed: (url) {
                    print(url);
                  },
                ),
              ),
              // Divider(
              //   color: const Color(0xFF167F67),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: ReadMoreText(
              //     'The Flutter framework builds its layout via the composition of widgets, everything that you construct programmatically is a widget and these are compiled together to create the user interface. ',
              //     trimLines: 2,
              //     style: TextStyle(color: Colors.black),
              //     colorClickableText: Colors.pink,
              //     trimMode: TrimMode.Line,
              //     trimCollapsedText: '...Read more',
              //     trimExpandedText: ' Less',
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
