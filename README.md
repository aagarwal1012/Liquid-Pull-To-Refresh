<div align="center"><img src="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/display/cover.png?raw=true"/></div>

# <div align="center">Liquid Pull To Refresh</div>
<div align="center"><p>A beautiful and custom refresh indicator for flutter highly inspired from <a href="https://dribbble.com/shots/1797373-Pull-Down-To-Refresh">Ramotion Pull Down to Refresh</a>.</p></div><br>

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
  <a href="https://codecov.io/gh/aagarwal1012/Liquid-Pull-To-Refresh">
    <img src="https://codecov.io/gh/aagarwal1012/Liquid-Pull-To-Refresh/branch/master/graph/badge.svg"
      alt="Codecov Coverage" />
  </a>
  	<a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-red.svg"
      alt="License: MIT" />
  </a>
  	<a href="https://www.paypal.me/aagarwal1012">
    <img src="https://img.shields.io/badge/Donate-PayPal-green.svg"
      alt="Donate" />
  </a>
</div><br>

# Table of contents

  * [Installing](#installing)
  * [Usage](#usage)
  * [Documentation](#documentation)
  * [Bugs or Requests](#bugs-or-requests)
  * [Donate](#donate)
  * [Contributors](#contributors-)
  * [License](#license)

# Installing

### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  liquid_pull_to_refresh: ^1.1.2
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

**Note -** `LiquidPullToRefresh` can only be used with a vertical scroll view.

For example:

```dart
LiquidPullToRefresh(
        key: _refreshIndicatorKey,	// key if you want to add
        onRefresh: _handleRefresh,	// refresh callback
        child: ListView(),		// scroll view
      );
```

If you do not want the opacity transition of child then set `showChildOpacityTransition: false`.  Preview regarding the both form of this widget is follows :-
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
<td style="text-align:center"><img src="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/display/liquid.gif?raw=true" height = "500px"/></td>
<td style="text-align:center"><img src="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/display/liquid_false.gif?raw=true" height = "500px"/></td>
</tr>
</tbody>
</table>
</div>

# Documentation

### LiquidPullToRefresh Class

| Dart attribute                        | Datatype                    | Description                                                  |     Default Value     |
| :------------------------------------ | :-------------------------- | :----------------------------------------------------------- | :-------------------: |
| child                                 | ScrollView                  | The widget below this widget in the tree.                    |       @required       |
| onRefresh                             | RefreshCallback             | A function that's called when the refreshing of page takes place. |       @required       |
| height                                | double                      | The distance from the child's top or bottom edge to where the box will settle after the spring effect. |         100.0         |
| springAnimationDurationInMilliseconds | int                         | Duration in milliseconds of springy effect that occurs when we leave dragging after full drag. |         1000          |
| borderWidth                           | double                      | Border width of progressing circle in Progressing Indicator. |          2.0          |
| showChildOpacityTransition            | bool                        | Whether to show child opacity transition or not.             |         true          |
| color                                 | Color                       | The progress indicator's foreground color.                   | ThemeData.accentColor |
| backgroundColor                       | Color                       | The progress indicator's background color.                   | ThemeData.canvasColor |
| notificationPredicate                 | ScrollNotificationPredicate | A check that specifies whether a `ScrollNotification` should be handled by this widget. |         null          |
| scrollController                      | ScrollController            | Controls the `ScrollView` child.                             |         null          |

For help on editing package code, view the [flutter documentation](https://flutter.io/developing-packages/).

# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues/new?template=feature_request.md) on GitHub and I'll look into it. Pull request are also welcome. 

See [Contributing.md](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/CONTRIBUTING.md).

# Donate
> If you found this project helpful or you learned something from the source code and want to thank me, consider buying me a cup of :coffee:
>
> - [PayPal](https://www.paypal.me/aagarwal1012/)

# Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/opannapo"><img src="https://avatars0.githubusercontent.com/u/18698574?v=4" width="100px;" alt=""/><br /><sub><b>opannapo</b></sub></a><br /><a href="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/commits?author=opannapo" title="Code">💻</a></td>
    <td align="center"><a href="https://taormina.io"><img src="https://avatars1.githubusercontent.com/u/1090627?v=4" width="100px;" alt=""/><br /><sub><b>Anthony Taormina</b></sub></a><br /><a href="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/commits?author=Taormina" title="Documentation">📖</a></td>
    <td align="center"><a href="http://kekland.github.io"><img src="https://avatars0.githubusercontent.com/u/14993994?v=4" width="100px;" alt=""/><br /><sub><b>Erzhan</b></sub></a><br /><a href="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/commits?author=kekland" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://bigdadz-developer.web.app/"><img src="https://avatars1.githubusercontent.com/u/23566790?v=4" width="100px;" alt=""/><br /><sub><b>Puttipong Wongrak</b></sub></a><br /><a href="https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/issues?q=author%3ABIGDADz" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome! See [Contributing.md](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/CONTRIBUTING.md).

# License
Liquid-Pull-To-Refresh is licensed under `MIT license`. View [license](https://github.com/aagarwal1012/Liquid-Pull-To-Refresh/blob/master/LICENSE).