## 0.5.0

[Breaking Change]: Changed "showBarrierColor" parameter in 'PopupController.show' method, to "showBarrier" parameter.
Now with "showBarrier" mode false, no material screen will be added before the original pop up
child.

Added support for Dart 3

Updated some deprecated flutter methods.

## 0.4.4

Now the "builder" parameter in 'PopupController.show' method, can return any widget, while it is
recommended to return either a 'Popup', or a 'Positioned' and similar widget.

## 0.4.3

Added new "builder" method in 'Popup' as well.

Updated documentation for "builder" parameter in 'PositionedAlign'.

## 0.4.2

Added new "builder" method in 'PositionedAlign'.

Now, no frame loss, in case of default alignment, Alignment.topLeft, in 'PositionedAlign'.

Fixed the bug in 'Popup', of no popup appearing when "animation" is true and "childSize" is null.

## 0.4.1+2

Updated documentation for 'Popup', 'PopupScope' and 'PopupController'.

## 0.4.1+1

Updated Changelog for version 0.4.0

## 0.4.1

Added many optional animation parameters in 'Popup'. Set 'animation' parameter in '
PopupController.show' method, to enable animations.

Added 'AnimatedInOut' new component.

## 0.4.0

[Breaking Change]: 'Popup' framework. Now create Popup by first generating PopupController using
BuildContext and show a Popup using 'show' method of the controller. Similarly close the 'Popup'
either using same controller or, getting the same controller from inside the Popup widget using its
context, and call the 'remove' method of the controller.

[Breaking Change]: Replaced 'box' parameter in 'PositionedAlign' to 'size'.

Now can select the point of contact between the popup and the parent widget, using the 'parentAlign'
parameter, to set the point according to the parent. And use 'childAlign' to set the alignment of
the child around that pont.

Added 'PopupScope' to create scoped 'Popup' widget, such that, 'Popup' does not go outside the
bounds of 'PopupScope' child widget.

Note:- Now 'Popup' uses 'PositionedAlign' for the child alignment so the 'Popup' will appear
"lazily", to prevent it, provide 'childSize' parameter of the 'Popup'.

## 0.3.1

Added new 'box' parameter in 'PositionedAlign', allowing 'synchronous' or 'NOT lazy' drawing of the
widget.

## 0.3.0

[Breaking Change]: Updated files architecture, to put each component inside "src" folder.

Added HelpfulComponentsTheme and HelpfulComponentsThemeData. Added CommonAlertDialogThemeData.

Added Parameters to the CommonAlertDialog: shape, elevation, textStyle, and showOkButton.

## 0.2.2

Added 2 New parameters in LazyBuilder, constraints and preventRedundantRebuilds.

Also fixed a Bug: LazyBuilder not re-generating the RenderBox on rebuild.

## 0.2.1

Added 2 New Components, LazyBuilder and PositionedAlign.

## 0.2.0

BREAKING CHANGE:
Made key parameter an optional named parameter in RowInfo Widget.

## 0.1.0

BREAKING CHANGES:

Added onError option in CommonAsyncSnapshotResponses Updated onLoading option in
CommonAsyncSnapshotResponses Added onLoading option in FutureDialog. Standardized parameter names in
FutureDialog, CommonAsyncSnapshotResponses to, onData, onLoading and onError.

## 0.0.3

Added debug and throwError option for FutureDialog and CommonAsyncSnapshotResponses.

## 0.0.2

Updated showPopup function.

## 0.0.1

Added many helpful components.
