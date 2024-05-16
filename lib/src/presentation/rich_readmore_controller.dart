import 'package:flutter/material.dart';

class RichReadMoreController extends ChangeNotifier {
  /// Callback to be called on press to read more.
  final VoidCallback? onPressReadMore;

  /// Callback to be called on press to read less.
  final VoidCallback? onPressReadLess;

  bool _readMore = true;

  bool _isExpandable = false;

  bool get isExpanded => _readMore;
  bool get isCollapsed => !_readMore;
  bool get isExpandable => _isExpandable;

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

  set isExpandable(bool value) {
    if (_isExpandable != value) {
      _isExpandable = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
