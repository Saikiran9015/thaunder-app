import 'package:equatable/equatable.dart';

abstract class DesignEvent extends Equatable {
  const DesignEvent();

  @override
  List<Object?> get props => [];
}

class UploadDesignEvent extends DesignEvent {
  final String filePath;

  const UploadDesignEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ProcessDesignEvent extends DesignEvent {
  final String filePath;
  final double scaleX;
  final double scaleY;
  final bool mirror;

  const ProcessDesignEvent({
    required this.filePath,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.mirror = false,
  });

  @override
  List<Object?> get props => [filePath, scaleX, scaleY, mirror];
}

class StartCuttingEvent extends DesignEvent {
  final List<String> gcode;

  const StartCuttingEvent(this.gcode);

  @override
  List<Object?> get props => [gcode];
}

class UpdateTransformEvent extends DesignEvent {
  final double dx;
  final double dy;
  final double scale;
  final double rotation;

  const UpdateTransformEvent({
    this.dx = 0,
    this.dy = 0,
    this.scale = 1.0,
    this.rotation = 0,
  });

  @override
  List<Object?> get props => [dx, dy, scale, rotation];
}

class ResetDesignEvent extends DesignEvent {
  const ResetDesignEvent();
}
