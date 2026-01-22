import 'package:equatable/equatable.dart';
import '../../data/models/device_model.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DevicesLoaded extends DeviceState {
  final List<DeviceModel> devices;

  const DevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceConnected extends DeviceState {
  final DeviceStatus status;

  const DeviceConnected(this.status);

  @override
  List<Object?> get props => [status];
}

class DeviceDisconnected extends DeviceState {}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceStatusUpdated extends DeviceState {
  final DeviceStatus status;

  const DeviceStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}
