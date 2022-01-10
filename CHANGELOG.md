## 3.0.1
* Fixed Deprecated Methods that are no longer used.
* General code cleanup.

## 3.0.0
* Added Null Safety to the package.

## 2.0.0
**Breaking Changes**

* Now Liquid Pull to Refresh supports any Widget as its `child` widget.
* Removed `notificationPredicate` and `scrollController` parameters.

**Enhancements**

* New parameter -- `animSpeedFactor` -- Controls the speed of the animation after refresh. Used to fasten the ending animation. [#33](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/33)

**Issues Fixed**

* Refresh indicator overlays on list view. [#46](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/46)
* Cannot trigger refresh programmatically using the global key. The method 'show' was called on null. [#37](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/37)

## 1.2.0
* Now Liquid Pull to Refresh supports **any Widget** as its `child` widget.

## 1.1.2
* Minor bug fixes.

 1.1.1
* Fixed the DiagnosticsNode error with error reporting that occurs with newer versions of Flutter.

## 1.1.0
* Added new parameter **scrollController** that can be added to control the `ScrollView` child.

## 1.0.2

## 1.0.1
* Fixed dart analysis issue.

## 1.0.0
* Initial Release.