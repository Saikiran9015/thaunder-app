import 'package:equatable/equatable.dart';

abstract class DesignState extends Equatable {
  const DesignState();

  @override
  List<Object?> get props => [];
}

class DesignInitial extends DesignState {}

class DesignLoading extends DesignState {}

class DesignUploaded extends DesignState {
  final Map<String, dynamic> designInfo;
  final double dx;
  final double dy;
  final double scale;
  final double rotation;

  const DesignUploaded(
    this.designInfo, {
    this.dx = 0,
    this.dy = 0,
    this.scale = 1.0,
    this.rotation = 0,
  });

  @override
  List<Object?> get props => [designInfo, dx, dy, scale, rotation];

  DesignUploaded copyWith({
    Map<String, dynamic>? designInfo,
    double? dx,
    double? dy,
    double? scale,
    double? rotation,
  }) {
    return DesignUploaded(
      designInfo ?? this.designInfo,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

class DesignProcessed extends DesignState {
  final List<String> gcode;
  final Map<String, dynamic> stats;

  const DesignProcessed(this.gcode, this.stats);

  @override
  List<Object?> get props => [gcode, stats];
}

class CuttingInProgress extends DesignState {
  final double progress;

  const CuttingInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DesignError extends DesignState {
  final String message;

  const DesignError(this.message);

  @override
  List<Object?> get props => [message];
}
