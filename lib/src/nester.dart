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
    List<_ListNextCalling> children, {
    Key? key,
    this.throwRangeException = false,
  })  : type = _NesterTypes.list,
        children = children.toList(),
        super(key: key);

  /// Manage the widgets list like a queue.
  /// Each time will be called the passed function will be consumed a child
  /// inside the queue.
  Nester.queue(
    List<_QueueNextCalling> children, {
    Key? key,
    this.throwRangeException = false,
  })  : type = _NesterTypes.queue,
        children = children.toList(),
        super(key: key);

  /// Manage the widgets list like a queue but add some extended function to
  /// the next calling function.
  Nester.extended(
    List<_ExtendedNextCalling> children, {
    Key? key,
    this.throwRangeException = false,
  })  : type = _NesterTypes.extended,
        children = children.toList(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _NesterTypes.list:
        return _List(
          children: children as List<_ListNextCalling>,
        ).elaborate();
      case _NesterTypes.queue:
        return _Queue(
          children: children as List<_QueueNextCalling>,
          throwRangeException: throwRangeException,
        ).elaborate();
      case _NesterTypes.extended:
        return _Queue(
          childrenExtended: children as List<_ExtendedNextCalling>,
          throwRangeException: throwRangeException,
        ).elaborate();
    }
  }
}

/// Define how to use Nester.
enum _NesterTypes {
  list,
  queue,
  extended,
}

/// Define the function call type for <list>
typedef _ListNextCalling = Widget Function(Widget);

/// Define the function call type for <queue>
typedef _QueueNextCalling = Widget Function(Function({int? skip, int? take}));

/// Define the function call type for <queue>
typedef _ExtendedNextCalling = Widget Function(
    Function({int? skip, int? take, dynamic param}), dynamic param);

/// The generic use of nester.
///
/// The children will be just a list Widget and every "next" will be in row
/// of the list at the next position.
class _List {
  /// The original children list
  final List<_ListNextCalling> children;

  /// Requested fields
  _List({required this.children});

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

/// Queue use of nester.
///
/// The children will be just a list Widget and every "next" will be consuming
/// the next position in the list.
/// Since the next calling are recursive the widget will be generated in cascade
/// starting from the last.
class _Queue {
  /// The original children list
  final List<_QueueNextCalling>? children;

  /// The extended children list.
  /// Will add the behavior to pass a parameter to the next call.
  final List<_ExtendedNextCalling>? childrenExtended;

  /// Define if need to throw ErrorRange exception
  final bool throwRangeException;

  /// Requested fields
  _Queue({
    this.children,
    this.childrenExtended,
    this.throwRangeException = false,
  });

  /// The current position in list
  int _currentIndex = 0;

  /// Get the list length.
  /// One of two list (children and childrenExtended) must be not null.
  int _getLength() {
    if (children != null) return children!.length;
    if (childrenExtended != null) return childrenExtended!.length;
    return 0;
  }

  /// Make the calling to the next function in the list
  _makeCalling(dynamic param) {
    // If over the bounds return an empty Container
    if (!throwRangeException && _currentIndex > _getLength() - 1) {
      return Container();
    }

    // Call the next item in list
    /// One of two list (children and childrenExtended) must be not null.
    if (children != null) {
      return children![_currentIndex](_next);
    }
    if (childrenExtended != null) {
      return childrenExtended![_currentIndex](_next, param);
    }
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
  /// Param [param] will passed to next calling as parameter.
  ///
  /// NOTE: If [skip] is not null and [take] is null an empty container will be
  /// returned.
  /// that [skip] param will be applied before [take].
  _next({int? skip, int? take, dynamic param}) {
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
      return _makeCalling(param);
    }

    // Multi case result
    List result = [];
    for (int index = 0; index < take; index++) {
      // Increment before calling
      _currentIndex++;

      // Avoid range error if required
      if (throwRangeException || _currentIndex < _getLength()) {
        result.add(_makeCalling(param));
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
    return _makeCalling(null);
  }
}
