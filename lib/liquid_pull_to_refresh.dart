library liquid_pull_to_refresh;

import 'package:flutter/material.dart';

class LiquidPullToRefresh extends RefreshIndicator {
  const LiquidPullToRefresh({
    Key key,
    Widget child,
    RefreshCallback onRefresh,
  }) : super(key: key, child: child, onRefresh: onRefresh);
}
