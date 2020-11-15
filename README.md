# Shaked Doron

## Dry Questions:

1. The class used to implement the controller pattern in this library is `SnappingSheetController`.
The features the above class allows the developer to conrol are:
	* `currentSnapPosition` - the current location of the snapping sheet in the screen.
	* `snapPositions` - the possible positions the snapping sheet allowed to be located in the screen. 

2. The parameter controlling the snapping into position with various different animations is `snappingCurve` which is a variable of type `Curve` inside the `SnapPosition` class. This value is the animation curve to this snapping position.

3. Both `InkWell` and `GestureDetector` provide features like `onTap`, `onLongPress`, etc. However, the main advantage of `InkWell` is its ability to create a ripple effect when the user taps the button (for example: https://flutter.dev/docs/cookbook/gestures/ripples). In the other hand, the main advantage of `GestureDetector` is the variaty of properties it controlls (for example: `onHorinzontalDragDown`, `onVerticalDragDown` etc). 