import 'package:flutter/widgets.dart';

/// Flutter library that automatically convert a list of widgets in a nested
/// group.
///
/// The only purpose of this library is to make the code more readable.
/// Since will using a cycle care about costs and benefits when you need to
/// have top performance.
class Nester extends StatelessWidget {
  /// Just need the list  of the widgets as children
  final List<Function(Widget)> children;

  /// Force to use a list of widgets
  const Nester(this.children, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// The list will be reversed to able to pass the current widget to the
    /// previous one.
    Widget next = Container();
    for (var element in children.reversed) {
      next = element(next);
    }

    /// The next widget will be never null
    return next;
  }
}
