import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  // constructor
  CollisionBlock({position, size, this.isPlatform = false})
      : super(
            //super is passing values to extended class (PositionComponent in this case)
            position: position,
            size: size) {
    // debugMode = true;
  }
}
