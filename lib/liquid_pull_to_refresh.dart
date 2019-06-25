library liquid_pull_to_refresh;

import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/src/circular_progress.dart';
import 'package:liquid_pull_to_refresh/src/clipper.dart';

// The over-scroll distance that moves the indicator to its maximum
// displacement, as a percentage of the scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

// How much the scroll's drag gesture can overshoot the LiquidPullToRefresh's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

// When the scroll ends, the duration of the progress indicator's animation
// to the LiquidPullToRefresh's displacement.
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

// The duration of the ScaleTransitionIn of box that starts when the
// refresh action has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// The signature for a function that's called when the user has dragged a
/// [LiquidPullToRefresh] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [LiquidPullToRefresh.onRefresh].
typedef RefreshCallback = Future<void> Function();

// The state machine moves through these modes only when the scrollable
// identified by scrollableKey has been scrolled to its min or max limit.
enum _LiquidPullToRefreshMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}

class LiquidPullToRefresh extends StatefulWidget {
  const LiquidPullToRefresh({
    Key key,
    @required this.child,
    @required this.onRefresh,
    this.color,
    this.decoration,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.height,
    this.springAnimationDurationInMilliseconds = 1000,
    this.borderWidth = 2.0,
    this.showChildOpacityTransition = true,
    this.scrollController,
  })  : assert(child != null),
        assert(onRefresh != null),
        assert(notificationPredicate != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// The progress indicator will be stacked on top of this child. The indicator
  /// will appear when child's Scrollable descendant is over-scrolled.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  final ScrollView child;

  /// The distance from the child's top or bottom edge to where the box
  /// will settle after the spring effect.
  ///
  /// default is set to 100.0
  final double height;

  /// Duration in milliseconds of springy effect that occurs when
  /// we leave dragging after full drag.
  ///
  /// default to 1000
  final int springAnimationDurationInMilliseconds;

  /// Border width of progressing circle in Progressing Indicator
  ///
  /// default to 2.0
  final double borderWidth;

  /// Whether to show child opacity transition or not.
  ///
  /// default to true
  final bool showChildOpacityTransition;

  /// A function that's called when the user has dragged the progress indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// The progress indicator's foreground color. The current theme's
  /// [Decoration] by default.
  final Decoration decoration;

  /// The progress indicator's foreground color. The current theme's
  /// [ThemeData.accentColor] by default.
  final Color color;

  /// The progress indicator's background color. The current theme's
  /// [ThemeData.canvasColor] by default.
  final Color backgroundColor;

  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. Set it to something
  /// else for more complicated layouts.
  final ScrollNotificationPredicate notificationPredicate;

  /// Controls the [ScrollView] child.
  /// [null] by default.
  final ScrollController scrollController;

  @override
  _LiquidPullToRefreshState createState() => _LiquidPullToRefreshState();
}

class _LiquidPullToRefreshState extends State<LiquidPullToRefresh>
    with TickerProviderStateMixin<LiquidPullToRefresh> {
  AnimationController _springController;
  Animation<double> _springAnimation;

  AnimationController _progressingController;
  Animation<double> _progressingRotateAnimation;
  Animation<double> _progressingPercentAnimation;
  Animation<double> _progressingStartAngleAnimation;

  AnimationController _ringDisappearController;
  Animation<double> _ringRadiusAnimation;
  Animation<double> _ringOpacityAnimation;

  AnimationController _showPeakController;
  Animation<double> _peakHeightUpAnimation;
  Animation<double> _peakHeightDownAnimation;

  AnimationController _indicatorMoveWithPeakController;
  Animation<double> _indicatorTranslateWithPeakAnimation;
  Animation<double> _indicatorRadiusWithPeakAnimation;

  AnimationController _indicatorTranslateInOutController;
  Animation<double> _indicatorTranslateAnimation;

  AnimationController _radiusController;
  Animation<double> _radiusAnimation;

  Animation<double> _childOpacityAnimation;

  AnimationController _positionController;
  Animation<double> _value;
  Animation<Color> _valueColor;

  _LiquidPullToRefreshMode _mode;
  Future<void> _pendingRefreshFuture;
  bool _isIndicatorAtTop;
  double _dragOffset;

  static final Animatable<double> _threeQuarterTween =
      Tween<double>(begin: 0.0, end: 0.75);
  static final Animatable<double> _oneToZeroTween =
      Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(vsync: this);
    _springAnimation =
        _springController.drive(Tween<double>(begin: 1.0, end: -1.0));

    _progressingController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _progressingRotateAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _progressingController,
      curve: Interval(0.0, 1.0),
    ));
    _progressingPercentAnimation =
        Tween<double>(begin: 0.25, end: 5 / 6).animate(CurvedAnimation(
      parent: _progressingController,
      curve: Interval(0.0, 1.0, curve: ProgressRingCurve()),
    ));
    _progressingStartAngleAnimation =
        Tween<double>(begin: -2 / 3, end: 1 / 2).animate(CurvedAnimation(
      parent: _progressingController,
      curve: Interval(0.5, 1.0),
    ));

    _ringDisappearController = AnimationController(vsync: this);
    _ringRadiusAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
        CurvedAnimation(
            parent: _ringDisappearController,
            curve: Interval(0.0, 0.2, curve: Curves.easeOut)));
    _ringOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ringDisappearController,
            curve: Interval(0.0, 0.2, curve: Curves.easeIn)));

    _showPeakController = AnimationController(vsync: this);
    _peakHeightUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _showPeakController,
            curve: Interval(0.1, 0.2, curve: Curves.easeOut)));
    _peakHeightDownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _showPeakController,
            curve: Interval(0.2, 0.3, curve: Curves.easeIn)));

    _indicatorMoveWithPeakController = AnimationController(vsync: this);
    _indicatorTranslateWithPeakAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _indicatorMoveWithPeakController,
            curve: Interval(0.1, 0.2, curve: Curves.easeOut)));
    _indicatorRadiusWithPeakAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _indicatorMoveWithPeakController,
            curve: Interval(0.1, 0.2, curve: Curves.easeOut)));

    _indicatorTranslateInOutController = AnimationController(vsync: this);
    _indicatorTranslateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _indicatorTranslateInOutController,
            curve: Interval(0.2, 0.6, curve: Curves.easeOut)));

    _radiusController = AnimationController(vsync: this);
    _radiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _radiusController, curve: Curves.easeIn));

    _positionController = AnimationController(vsync: this);
    _value = _positionController.drive(_threeQuarterTween);

    _childOpacityAnimation = _positionController.drive(_oneToZeroTween);
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
              begin: (widget.color ?? theme.accentColor).withOpacity(0.0),
              end: (widget.color ?? theme.accentColor).withOpacity(1.0))
          .chain(CurveTween(
              curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _springController.dispose();
    _progressingController.dispose();
    _positionController.dispose();
    _ringDisappearController.dispose();
    _showPeakController.dispose();
    _indicatorMoveWithPeakController.dispose();
    _indicatorTranslateInOutController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    if (notification is ScrollStartNotification &&
        notification.metrics.extentBefore == 0.0 &&
        _mode == null &&
        _start(notification.metrics.axisDirection)) {
      setState(() {
        _mode = _LiquidPullToRefreshMode.drag;
      });
      return false;
    }
    bool indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed)
        _dismiss(_LiquidPullToRefreshMode.canceled);
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_LiquidPullToRefreshMode.canceled);
        } else {
          _dragOffset -= notification.scrollDelta;
          _checkDragOffset(notification.metrics.viewportDimension);
        }
      }
      if (_mode == _LiquidPullToRefreshMode.armed &&
          notification.dragDetails == null) {
        // On iOS start the refresh when the Scrollable bounces back from the
        // OverScroll (ScrollNotification indicating this don't have dragDetails
        // because the scroll activity is not directly triggered by a drag).
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _LiquidPullToRefreshMode.drag ||
          _mode == _LiquidPullToRefreshMode.armed) {
        _dragOffset -= notification.overscroll / 2.0;
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _LiquidPullToRefreshMode.armed:
          _show();
          break;
        case _LiquidPullToRefreshMode.drag:
          _dismiss(_LiquidPullToRefreshMode.canceled);
          break;
        default:
          // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_mode == _LiquidPullToRefreshMode.drag) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  // Stop showing the progress indicator.
  Future<void> _dismiss(_LiquidPullToRefreshMode newMode) async {
    await Future<void>.value();
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == _LiquidPullToRefreshMode.canceled ||
        newMode == _LiquidPullToRefreshMode.done);
    setState(() {
      _mode = newMode;
    });
    switch (_mode) {
      case _LiquidPullToRefreshMode.done:
        //stop progressing animation
        _progressingController.stop();

        // progress ring disappear animation
        _ringDisappearController.animateTo(1.0,
            duration: Duration(
                milliseconds: widget.springAnimationDurationInMilliseconds),
            curve: Curves.linear);

        // indicator translate out
        _indicatorMoveWithPeakController.animateTo(0.0,
            duration: Duration(
                milliseconds: widget.springAnimationDurationInMilliseconds),
            curve: Curves.linear);
        _indicatorTranslateInOutController.animateTo(0.0,
            duration: Duration(
                milliseconds: widget.springAnimationDurationInMilliseconds),
            curve: Curves.linear);

        //initial value of controller is 1.0
        await _showPeakController.animateTo(0.3,
            duration: Duration(
                milliseconds:
                    (widget.springAnimationDurationInMilliseconds).round()),
            curve: Curves.linear);

        _radiusController.animateTo(0.0,
            duration: Duration(
                milliseconds:
                    (widget.springAnimationDurationInMilliseconds / 5).round()),
            curve: Curves.linear);

        _showPeakController.value = 0.175;
        await _showPeakController.animateTo(0.1,
            duration: Duration(
                milliseconds:
                    (widget.springAnimationDurationInMilliseconds / 5).round()),
            curve: Curves.easeOut);
        _showPeakController.value = 0.0;

        await _positionController.animateTo(0.0,
            duration: Duration(
                milliseconds: _kIndicatorSnapDuration.inMilliseconds * 2));
        break;

      case _LiquidPullToRefreshMode.canceled:
        await _positionController.animateTo(0.0,
            duration: _kIndicatorScaleDuration);
        break;
      default:
        assert(false);
    }
    if (mounted && _mode == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _mode = null;
      });
    }
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.up:
        _isIndicatorAtTop = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _positionController.value = 0.0;
    _springController.value = 0.0;
    _progressingController.value = 0.0;
    _ringDisappearController.value = 1.0;
    _showPeakController.value = 0.0;
    _indicatorMoveWithPeakController.value = 0.0;
    _indicatorTranslateInOutController.value = 0.0;
    _radiusController.value = 1.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_mode == _LiquidPullToRefreshMode.drag ||
        _mode == _LiquidPullToRefreshMode.armed);
    double newValue =
        _dragOffset / (containerExtent * _kDragContainerExtentPercentage);
    if (_mode == _LiquidPullToRefreshMode.armed)
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    _positionController.value =
        newValue.clamp(0.0, 1.0); // this triggers various rebuilds
    if (_mode == _LiquidPullToRefreshMode.drag &&
        _valueColor.value.alpha == 0xFF) _mode = _LiquidPullToRefreshMode.armed;
  }

  void _show() {
    assert(_mode != _LiquidPullToRefreshMode.refresh);
    assert(_mode != _LiquidPullToRefreshMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _LiquidPullToRefreshMode.snap;

    _positionController.animateTo(1.0 / _kDragSizeFactorLimit,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    _showPeakController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    //indicator translate in with peak
    _indicatorMoveWithPeakController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    //indicator move to center
    _indicatorTranslateInOutController.animateTo(1.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds),
        curve: Curves.linear);

    // progress ring fade in
    _ringDisappearController.animateTo(0.0,
        duration: Duration(
            milliseconds: widget.springAnimationDurationInMilliseconds));

    _springController
        .animateTo(0.5,
            duration: Duration(
                milliseconds: widget.springAnimationDurationInMilliseconds),
            curve: Curves.elasticOut)
        .then<void>((void value) {
      if (mounted && _mode == _LiquidPullToRefreshMode.snap) {
        assert(widget.onRefresh != null);

        setState(() {
          // Show the indeterminate progress indicator.
          _mode = _LiquidPullToRefreshMode.refresh;
        });

        //run progress animation
        _progressingController..repeat();

        final Future<void> refreshResult = widget.onRefresh();
        assert(() {
          if (refreshResult == null) {
            // See https://github.com/flutter/flutter/issues/31962#issuecomment-488882515
            // Delete this code when the new context update reaches stable versions of Flutter.
            final bool _useDiagnosticsNode =
                FlutterError('text') is Diagnosticable;

            dynamic safeContext(String context) {
              return _useDiagnosticsNode
                  ? DiagnosticsNode.message(context)
                  : context;
            }

            FlutterError.reportError(FlutterErrorDetails(
              exception: FlutterError('The onRefresh callback returned null.\n'
                  'The LiquidPullToRefresh onRefresh callback must return a Future.'),
              context: safeContext('when calling onRefresh'),
              library: 'LiquidPullToRefresh library',
            ));
          }
          return true;
        }());

        if (refreshResult == null) return;

        refreshResult.whenComplete(() {
          if (mounted && _mode == _LiquidPullToRefreshMode.refresh) {
            completer.complete();

            _dismiss(_LiquidPullToRefreshMode.done);
          }
        });
      }
    });
  }

  /// Show the progress indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [LiquidPullToRefresh] with a [GlobalKey<LiquidPullToRefreshState>]
  /// makes it possible to refer to the [LiquidPullToRefreshState].
  ///
  /// The future returned from this method completes when the
  /// [LiquidPullToRefresh.onRefresh] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].
  ///
  /// When initiated in this manner, the progress indicator is independent of any
  /// actual scroll view. It defaults to showing the indicator at the top. To
  /// show it at the bottom, set `atTop` to false.
  Future<void> show({bool atTop = true}) {
    if (_mode != _LiquidPullToRefreshMode.refresh &&
        _mode != _LiquidPullToRefreshMode.snap) {
      if (_mode == null) _start(atTop ? AxisDirection.down : AxisDirection.up);
      _show();
    }
    return _pendingRefreshFuture;
  }

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    // assigning default color and background color
    Color _defaultColor = Theme.of(context).accentColor;
    Color _defaultBackgroundColor = Theme.of(context).canvasColor;

    // assigning default height
    double _defaultHeight = 100.0;
    // checking whether to take default values or not
    Decoration decoration = widget.decoration ?? (widget.color != null ? BoxDecoration(color: widget.color) : null);

    // checking whether to take default values or not
    Color color = (widget.color != null) ? widget.color : _defaultColor;
    Color backgroundColor = (widget.backgroundColor != null)
        ? widget.backgroundColor
        : _defaultBackgroundColor;
    double height = (widget.height != null) ? widget.height : _defaultHeight;

    // converting list items to slivers
    List<Widget> slivers =
        // ignore: invalid_use_of_protected_member
        List.from(widget.child.buildSlivers(context), growable: true);

    //Code Added for testing
//    slivers.insert(
//      0,
//      SliverToBoxAdapter(
//        child: ClipPath(
//          clipper: HillClipper(
//            centreHeight: 100,
//            curveHeight: 50.0,
//            peakHeight: 30.0,
//            peakWidth: 15.0 * 5 / 2,
//          ),
//          child: Container(
//            height: 100.0,
//            color: Colors.yellow,
//            child: Align(
//              alignment: Alignment(0.0, 1.0),
//              child: Opacity(
//                opacity: 1.0,
//                child: CircularProgress(
//                  progressCircleOpacity: 1.0,
//                  innerCircleRadius: 15.0,
//                  progressCircleBorderWidth: 0.0,
//                  progressCircleRadius: 0.0,
//                  progressPercent: 0.5,
//                ),
//              ),
//            ),
//          ),
//        ),
//      ),
//    );

    final Widget child = NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: slivers,
        ),
      ),
    );
    if (_mode == null) {
      assert(_dragOffset == null);
      assert(_isIndicatorAtTop == null);
      return child;
    }
    assert(_dragOffset != null);
    assert(_isIndicatorAtTop != null);

    slivers.insert(
      0,
      SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _positionController,
          builder: (BuildContext buildContext, Widget child) {
            return Container(
              height: _value.value * height * 2, //100.0
            );
          },
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: _positionController,
          builder: (BuildContext buildContext, Widget child) {
            return Opacity(
              // -0.01 is done for elasticOut curve
              opacity: (widget.showChildOpacityTransition)
                  ? (_childOpacityAnimation.value - (1 / 3) - 0.01)
                      .clamp(0.0, 1.0)
                  : 1.0,
              child: NotificationListener<ScrollNotification>(
                key: _key,
                onNotification: _handleScrollNotification,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: _handleGlowNotification,
                  child: CustomScrollView(
                    controller: widget.scrollController,
                    slivers: slivers,
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            _positionController,
            _springController,
            _showPeakController,
          ]),
          builder: (BuildContext buildContext, Widget child) {
            return ClipPath(
              clipper: CurveHillClipper(
                centreHeight: height,
                curveHeight: height / 2 * _springAnimation.value, // 50.0
                peakHeight: height *
                    3 /
                    10 *
                    ((_peakHeightUpAnimation.value != 1.0) //30.0
                        ? _peakHeightUpAnimation.value
                        : _peakHeightDownAnimation.value),
                peakWidth: (_peakHeightUpAnimation.value != 0.0 &&
                        _peakHeightDownAnimation.value != 0.0)
                    ? height * 35 / 100 //35.0
                    : 0.0,
              ),
              child: Container(
                height: _value.value * height * 2, // 100.0 
                decoration: decoration,
              ),
            );
          },
        ),
        Container(
          height: height, //100.0
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _progressingController,
              _ringDisappearController,
              _indicatorMoveWithPeakController,
              _indicatorTranslateInOutController,
              _radiusController,
            ]),
            builder: (BuildContext buildContext, Widget child) {
              return Align(
                alignment: Alignment(
                  0.0,
                  (1.0 -
                      (0.36 * _indicatorTranslateWithPeakAnimation.value) -
                      (0.64 * _indicatorTranslateAnimation.value)),
                ),
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(_progressingRotateAnimation.value * 5 * pi / 6),
                  alignment: FractionalOffset.center,
                  child: CircularProgress(
                    backgroundColor: backgroundColor,
                    progressCircleOpacity: _ringOpacityAnimation.value,
                    innerCircleRadius: height *
                        15 /
                        100 * // 15.0
                        ((_mode != _LiquidPullToRefreshMode.done)
                            ? _indicatorRadiusWithPeakAnimation.value
                            : _radiusAnimation.value),
                    progressCircleBorderWidth: widget.borderWidth,
                    //2.0
                    progressCircleRadius: (_ringOpacityAnimation.value != 0.0)
                        ? (height * 2 / 10) * _ringRadiusAnimation.value //20.0
                        : 0.0,
                    startAngle: _progressingStartAngleAnimation.value * pi,
                    progressPercent: _progressingPercentAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProgressRingCurve extends Curve {
  @override
  double transform(double t) {
    if (t <= 0.5) {
      return 2 * t;
    } else {
      return 2 * (1 - t);
    }
  }
}
