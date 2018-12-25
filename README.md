<div align="center"><img src="/display/cover.png"/></div>

# <div align="center">Liquid Pull To Refresh</div>
<div align="center">A beautiful and custom refresh indicator highly inspired from <a src = "https://dribbble.com/shots/1797373-Pull-Down-To-Refresh">Ramotion Pull Down to Refresh</a> for flutter.</div><br>

<div align="center">
	<a href="https://flutter.io">
    <img src="https://img.shields.io/badge/Platform-Flutter-yellow.svg"
      alt="Platform" />
  </a>
  	<a href="https://pub.dartlang.org/packages/liquid_pull_to_refresh">
    <img src="https://img.shields.io/pub/v/liquid_pull_to_refresh.svg"
      alt="Pub Package" />
  </a>
  	<a href="https://travis-ci.com/aagarwal1012/Liquid-Pull-To-Refresh">
    <img src="https://travis-ci.com/aagarwal1012/Liquid-Pull-To-Refresh.svg?token=pXLTRcXnVLpccbxqiWBi&branch=master"
      alt="Build Status" />
  </a>
  	<a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-red.svg?style=flat-square"
      alt="License: MIT" />
  </a>
</div><br>

# Table of contents

  * [Installing](#installing)
  * [Usage](#usage)
  * [Documentation](#documentation)
  * [Bugs or Requests](#bugs-or-requests)
  * [License](#license)

# Installing

### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  liquid_pull_to_refresh: ^1.0.0
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```css
$ pub get
```

with `Flutter`:

```css
$ flutter packages get
```

### 3. Import it

Now in your `Dart` code, you can use: 

```dart
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
```


# Usage

For adding this custom refresh indicator in your flutter app, you have to simply wrap *ListView*  or *GridView* inside `LiquidPullToRefresh`. Also you have provide the value of `onRefresh` parameter which is a refresh callback. 

**Note - **`LiquidPullToRefresh` can only be used with a vertical scroll view.

For example:

```dart
LiquidPullToRefresh(
        key: _refreshIndicatorKey,	// key if you want to add
        onRefresh: _handleRefresh,	// refresh callback
        child: ListView(),			// scroll view
      );
```

If you do not want the opacity transition of child then set `showChildOpacityTransition: false`.  Preview regarding the both form of this widget is follows -
<div align="center">
<table>
<thead>
<tr>
<th style="text-align:center"><code>showChildOpacityTransition: true</code></th>
<th style="text-align:center"><code>showChildOpacityTransition: false</code></th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:center"><img src="/display/liquid.gif" height = "500px"/></td>
<td style="text-align:center"><img src="/display/liquid_false.gif" height = "500px"/></td>
</tr>
</tbody>
</table>
</div>

# Documentation

### LiquidPullToRefresh Class

| Dart attribute                        | Datatype                    | Description                                                  |         Default Value         |
| :------------------------------------ | :-------------------------- | :----------------------------------------------------------- | :---------------------------: |
| child                                 | ScrollView                  | The widget below this widget in the tree.                    |           @required           |
| onRefresh                             | RefreshCallback             | A function that's called when the refreshing of page takes place. |           @required           |
| height                                | double                      | The distance from the child's top or bottom edge to where the box will settle after the spring effect. |             100.0             |
| springAnimationDurationInMilliseconds | int                         | Duration in milliseconds of springy effect that occurs when we leave dragging after full drag. |             1000              |
| borderWidth                           | double                      | Border width of progressing circle in Progressing Indicator. |              2.0              |
| showChildOpacityTransition            | bool                        | Whether to show child opacity transition or not.             |             true              |
| color                                 | Color                       | The progress indicator's foreground color.                   |     ThemeData.accentColor     |
| backgroundColor                       | Color                       | The progress indicator's background color.                   |     ThemeData.canvasColor     |
| notificationPredicate                 | ScrollNotificationPredicate | A check that specifies whether a `ScrollNotification` should be handled by this widget. |             null              |

For help on editing package code, view the [flutter documentation](https://flutter.io/developing-packages/).

# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/new?template=feature_request.md) on GitHub and I'll look into it. Pull request are also welcome. 

See [Contributing.md](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/CONTRIBUTING.md).

# License
Animated-Text-Kit is licensed under `MIT license`. View [license](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/LICENSE).
