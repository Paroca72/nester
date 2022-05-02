# nester

Flutter library to convert a list of widgets in a nested group of
widgets.  
A beautifier plugin to easing your code syntax.

## Features

- Ease the code syntax
- Can manage like a generic list
- Can manage like a queue


## Installation

- Add the dependency

```
dependencies:
  nester: ^1.1.1
```

- Import the package

```
import 'package:nester/nester.dart';
```

## Example Usage

#### NESTER LIST
Will treated the as simple list. You are allowed to have just one
**"next"**
reference for each item in the list.
This is the most simple way to use **Nester**.
Recommended when you mostly have "one child" Widget inside your list.


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

**NOTE:** The last `next` item in list will be always an empty
`Container` object. So is useless to pass it.

---

#### NESTER QUEUE
The Widget list will be treated like a queue.
Every **"next"** calling will consume the next item in the list.
This is useful when you using "multi-child" Widgets inside your list.


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

**Skip and Take**

The `next({int skip, int take})` function accept two parameters.
* Param `skip` will skip n calls on the queue list. Note that the
function wil NOT check for nested calling, just skip the next n items
inside the list. `skip` will be always applied before `take`.
* Param `take` will consuming n items on the same level. If a item have a
nested calling will not count as consumed. The result will be an array of
Widgets.


**Constraints**

* if `skip` and `take` are less than 0 will be considered 0
* if `skip` is not null or 0 and `take` is null an empty Container
will be returned.

**Throw Range Exception**

The `queue` constructor accept `throwRangeException` (default:
`false`) to avoid the RangeError check.
If `true` every calling of `next` then exceed the list boundaries will
throw a `RangeError` exception.

When use `take` param the resulting array will not exceed the number of
remaining items in list.
When NOT use `take` and the `next` calling exceed the list bounds an
empty `Container` will be returned.

---

##### Deep in queue mode

Using of `skip` and `take` parameters could create confusion so
write some examples to explain better them behavior.

Suppose the have a variable `trigger` boolean to use to skip some items
inside a `Column` widget.

```dart
    return Nester.queue([
      ...,
     (next) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              next(skip: trigger ? 0: 2),
              next(),
              next(),
            ]),
      (next) => Padding(..., child: next()),
      (_) => const Text("If trigger true"),
      (_) => const Text("Always show"),
      (_) => const Text("Always show"),
    ]);
```

**OR**

```dart
    return Nester.queue([
      ...,
     (next) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: []
              ..addAll(next(skip: trigger ? 0: 2, take: trigger ? 1: 0))
              ..addAll(next(take: 2)),
            ),
      (next) => Padding(..., child: next()),
      (_) => const Text("If trigger true"),
      (_) => const Text("Always show"),
      (_) => const Text("Always show"),
    ]);
```

If `trigger` is true `skip` 0 and `take` 1.  
If `trigger` is false `skip` 2 and `take` 0.

**Why skip = 2?**  
Because skip will not go inside the tree to check the nested items.
Just skip the items on the raw list.
So need to skip the next `Padding` and `Text` (*two items*).  
Instead `take` will consume all the item inside the tree. Take 1 it
mean consuming the next `Padding` then will consume the next `Text`
(*two items*).

**Why addAll?**  
Because when you use `take` parameter the result will be always an
Array of Widgets, even if the taking is 0 or 1.