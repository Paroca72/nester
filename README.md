# nester

Flutter library to convert a list of widgets in a nested group of widgets.  
A beautifier plugin to easing your code syntax.

## Features

- Ease the code syntax
- Can manage like a generic list
- Can manage like a queue

## Installation

- Add the dependency

```
dependencies:
  nester: ^0.0.5
```

- Import the package

```
import 'package:nester/nester.dart';
```

## Example Usage

#### NESTER LIST
Will treat the as simple list. You are allowed to have just one **"next"**
reference for each item in the list.
This is the most simple and way to use **Nester**.
Recommended when you have mostly "one child" Widget inside your list.


###### Original code
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
      );
```

###### Using Nester
```dart
   return Nester.list([
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
  ]);
```

#### NESTER QUEUE
The Widget list will be treated like a queue.
Every **"next"** calling will consume the next item in the list.
This is very useful when you are using "multi-child" Widget inside
your list.

###### Original code
```dart
   return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Text("Left", textAlign: TextAlign.left),
              Text("Center", textAlign: TextAlign.center),
              Text("Right", textAlign: TextAlign.right),
            ],
          ),
        ),
      ),
    );
```

###### Using Nester
```dart
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
            children: next(take: 3), // or [ next(), next(), next() ],
          ),
      (_) => const Text("Left", textAlign: TextAlign.left),
      (_) => const Text("Center", textAlign: TextAlign.center),
      (_) => const Text("Right", textAlign: TextAlign.right),
    ]);
```

The `next({int skip, int take})` accept two parameters.
* Param `skip` will skip n calling on the queue list. Note that the
function wil NOT check for nested calling, just skip the next n items
inside the list.
* Param `take` will consuming n item on the same level. If a item have a
nested calling will not count as consumed. The result will be an array of
Widget.

**NOTE** that `skip` param will be applied before `take`.
