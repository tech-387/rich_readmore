import 'package:flutter/material.dart';

class RichReadMoreController extends ChangeNotifier {
  /// Callback to be called on press to read more.
  final VoidCallback? onPressReadMore;

  /// Callback to be called on press to read less.
  final VoidCallback? onPressReadLess;

  bool _readMore = true;

  bool get isExpanded => _readMore;
  bool get isCollapsed => !_readMore;

  RichReadMoreController({
    this.onPressReadLess,
    this.onPressReadMore,
  });

  void onTapLink() {
    _readMore = !_readMore;
    if (_readMore) {
      onPressReadLess?.call();
    } else {
      onPressReadMore?.call();
    }
    notifyListeners();
  }
}
