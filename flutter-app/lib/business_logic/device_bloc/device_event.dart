import 'package:equatable/equatable.dart';


abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevicesEvent extends DeviceEvent {
  const LoadDevicesEvent();
}

class ConnectDeviceEvent extends DeviceEvent {
  final String port;

  const ConnectDeviceEvent(this.port);

  @override
  List<Object?> get props => [port];
}

class DisconnectDeviceEvent extends DeviceEvent {
  const DisconnectDeviceEvent();
}

class RefreshDeviceStatusEvent extends DeviceEvent {
  const RefreshDeviceStatusEvent();
}

class HomeDeviceEvent extends DeviceEvent {
  const HomeDeviceEvent();
}

class EmergencyStopEvent extends DeviceEvent {
  const EmergencyStopEvent();
}
