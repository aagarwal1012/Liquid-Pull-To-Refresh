library liquid_pull_to_refresh;

import 'package:flutter/material.dart';

class LiquidPullToRefresh extends RefreshIndicator {
  const LiquidPullToRefresh({
    Key key,
    @required Widget child,
    double displacement = 40.0,
    @required RefreshCallback onRefresh,
    Color color,
    Color backgroundColor,
    ScrollNotificationPredicate notificationPredicate =
        defaultScrollNotificationPredicate,
    String semanticsLabel,
    String semanticsValue,
  }) : super(
          key: key,
          child: child,
          displacement: displacement,
          onRefresh: onRefresh,
          color: color,
          notificationPredicate: notificationPredicate,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

//  @override
//  _LiquidPullToRefreshState createState() => _LiquidPullToRefreshState();
}

class _LiquidPullToRefreshState extends RefreshIndicatorState {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
