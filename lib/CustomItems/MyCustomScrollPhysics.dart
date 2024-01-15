import 'package:flutter/material.dart';

class MyCustomScrollPhysics extends ScrollPhysics {
  const MyCustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  MyCustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyCustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Implement your custom scrolling behavior here
    // You can manipulate the offset or apply custom logic
    return super.applyPhysicsToUserOffset(position, offset);
  }

// You can override more methods to customize the behavior
}


class MyBouncingScrollPhysics extends BouncingScrollPhysics {
  const MyBouncingScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  MyBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyBouncingScrollPhysics(parent: buildParent(ancestor));
  }

// You can override more methods to customize the behavior
}