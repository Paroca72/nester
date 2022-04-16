import 'package:flutter/widgets.dart';

/// Flutter library that automatically convert a list of widgets in a nested
/// group.
///
/// The only purpose of this library is to make the code more readable.
/// Since will using a cycle, or in case of "queue" mode a recursion, care
/// about costs and benefits when you need to have top performance.
class Nester extends StatelessWidget {
  /// The original children object list
  final Object children;

  /// Define the management type of the children
  final _NesterTypes type;

  /// Force to use a list of widgets
  @Deprecated(
      "Will be removed in the next versions. Use 'Nester.list' instead.")
  Nester(List<Widget Function(Widget)> children, {Key? key})
      : type = _NesterTypes.list,
        children = children.toList(),
        super(key: key);

  /// Force to use a list of widgets
  Nester.list(List<Widget Function(Widget)> children, {Key? key})
      : type = _NesterTypes.list,
        children = children.toList(),
        super(key: key);

  /// Manage the widgets list like a queue.
  /// Each time will be called the passed function will be consumed a child
  /// inside the queue.
  Nester.queue(List<Widget Function(Widget Function())> children, {Key? key})
      : type = _NesterTypes.queue,
        children = children.toList(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _NesterTypes.list:
        return _List(children as List<Widget Function(Widget)>).elaborate();
      case _NesterTypes.queue:
        return _Queue(children as List<Function(Widget Function())>)
            .elaborate();
    }
  }
}

/// Define how to use Nester.
enum _NesterTypes {
  list,
  queue,
}

/// Define the generic use of nester.
///
/// The children will be just a list Widget and every "next" will be in row
/// of the list at the next position.
class _List {
  /// The original children list
  final List<Widget Function(Widget)> children;

  /// Requested fields
  _List(this.children);

  /// Elaborate the list
  Widget elaborate() {
    // The list will be reversed to able to pass the current widget to the
    // previous one.
    Widget next = Container();
    for (var child in children.reversed) {
      next = child(next);
    }

    // The next widget will be never null
    return next;
  }
}

/// Define the queue use of nester.
///
/// The children will be just a list Widget and every "next" will be consuming
/// the next position in the list.
/// Since the next calling are recursive the widget will be generated in cascade
/// starting from the last.
class _Queue {
  /// The original children list
  final List<Function(Widget Function())> children;

  /// Requested fields
  _Queue(this.children);

  /// The current position in list
  int currentIndex = 0;

  /// This will call the next Widget in the tree
  Widget _next() {
    // Check the bounds
    if (currentIndex > children.length) {
      throw Exception("Index out of bounds");
    }

    // Get the next Widget in queue
    return children[++currentIndex](_next);
  }

  /// Elaborate the list
  Widget elaborate() {
    // Check for empty values
    if (children.isEmpty) {
      return Container();
    }

    // Call the first function in the list.
    // Than should be work in cascade as inside the function we expect
    // will be called the "_next" function recursively for each branch.
    return (children[currentIndex])(_next);
  }
}
