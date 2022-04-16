import 'package:flutter/material.dart';
import 'package:nester/nester.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Nester.queue([
      (next) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: next(),
          ),
      (next) => Scaffold(
            appBar: next() as PreferredSizeWidget,
            body: next(),
          ),
      (_) => AppBar(title: const Text("Example")),
      (next) => Padding(
            padding: const EdgeInsets.all(50),
            child: next(),
          ),
      (next) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [ next(), next(), next() ],
          ),
      (_) => const Text("Left", textAlign: TextAlign.left),
      (_) => const Text("Center", textAlign: TextAlign.center),
      (_) => const Text("Right", textAlign: TextAlign.right),
    ]);

  }
}
