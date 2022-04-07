# nester

Flutter library to automatically convert a list of widgets in a nested group of widget.
This is just different way to view the code "in list" instead the default "nested" widgets pattern.

## Features

- Ease the code reading

## Installation

- Add the dependency

```
dependencies:
  nester: ^0.0.2
```

- Import the package

```
import 'package:nester/nester.dart';
```

## Example Usage

#### **Original code**

```dart
return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            color: Colors.black12,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[Text("Just a description")],
              ),
            ),
          ),
        ),
      ),
```

#### **Using Nester**

```dart
return Nester(
    [
        (next) => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue),
              home: next,
            ),
        (next) => Scaffold(
              appBar: AppBar(title: const Text("Example")),
              body: next,
            ),
        (next) => Padding(
              padding: const EdgeInsets.all(20),
              child: next,
            ),
        (next) => Container(
              color: Colors.black12,
              child: next,
            ),
        (next) => Center(child: next),
        (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[Text("Just a text")],
            ),
  ]
);
```
