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

  /// Only for Queue mode define if throw ErrorRange exception
  final bool throwRangeException;

  /// Force to use a list of widgets
  Nester.list(
    List<Widget Function(Widget)> children, {
    Key? key,
    this.throwRangeException = false,
  })  : type = _NesterTypes.list,
        children = children.toList(),
        super(key: key);

  /// Manage the widgets list like a queue.
  /// Each time will be called the passed function will be consumed a child
  /// inside the queue.
  Nester.queue(
    List<Widget Function(Function({int? skip, int? take}))> children, {
    Key? key,
    this.throwRangeException = false,
  })  : type = _NesterTypes.queue,
        children = children.toList(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _NesterTypes.list:
        return _List(children as List<Widget Function(Widget)>).elaborate();
      case _NesterTypes.queue:
        return _Queue(
          children as List<Widget Function(Function({int? skip, int? take}))>,
          throwRangeException,
        ).elaborate();
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
  final List<Widget Function(Function({int? skip, int? take}))> children;

  /// Define if need to throw ErrorRange exception
  final bool throwRangeException;

  /// Requested fields
  _Queue(this.children, this.throwRangeException);

  /// The current position in list
  int _currentIndex = 0;

  /// Make the calling to the next function in the list
  _makeCalling() {
    // If over the bounds return an empty Container
    if (!throwRangeException && _currentIndex > children.length - 1) {
      return Container();
    }

    // Call the next item in list
    return children[_currentIndex](_next);
  }

  /// This will call the next Widget in the tree
  ///
  /// Param [skip] will skip n calling on the queue list. Note that the
  /// function wil NOT check for nested calling, just skip the next n items
  /// inside the list.
  ///
  /// Param [take] will consuming n item on the same level. If a item have a
  /// nested calling will not count as consumed. The result will be an array of
  /// Widget.
  ///
  /// If [skip] is not null and [take] is null an empty container will be
  /// returned.
  ///
  /// NOTE that [skip] param will be applied before [take].
  _next({int? skip, int? take}) {
    // Apply skip
    skip = skip == null || skip < 0 ? 0 : skip;
    _currentIndex += skip;

    // Single case result
    if (take == null) {
      // If [skip] is not null an return a Container
      if (skip > 0) {
        return Container();
      }

      // Increment before calling
      _currentIndex++;
      return _makeCalling();
    }

    // Multi case result
    List result = [];
    for (int index = 0; index < take; index++) {
      // Increment before calling
      _currentIndex++;

      // Avoid range error if required
      if (throwRangeException || _currentIndex < children.length) {
        result.add(_makeCalling());
      }
    }
    return result.cast<Widget>();
  }

  /// Elaborate the list
  Widget elaborate() {
    // Call the first function in the list.
    // after the next calling should be work in cascade because inside the
    // next function we expect to be called the "_next" function recursively
    // for each branch.
    return _makeCalling();
  }
}
