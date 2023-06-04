import 'package:readmore/data/models/trim_modes.dart';

abstract class ReadMoreSettings {
  final TrimMode trimMode;

  ReadMoreSettings({
    required this.trimMode,
  });
}

class LineModeSettings extends ReadMoreSettings {
  final int trimLines;

  /// Settings for trim using line numbers
  LineModeSettings({required this.trimLines}) : super(trimMode: TrimMode.line);
}

class LengthModeSettings extends ReadMoreSettings {
  final int trimLength;

  /// Settings form trim using characters length
  LengthModeSettings({required this.trimLength})
      : super(trimMode: TrimMode.length);
}
