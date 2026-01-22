import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/device_repository.dart';
import 'device_event.dart';
import 'device_state.dart';

export 'device_event.dart';
export 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository _deviceRepository;

  DeviceBloc(this._deviceRepository) : super(DeviceInitial()) {
    on<LoadDevicesEvent>(_onLoadDevices);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<RefreshDeviceStatusEvent>(_onRefreshDeviceStatus);
    on<HomeDeviceEvent>(_onHomeDevice);
    on<EmergencyStopEvent>(_onEmergencyStop);
  }

  Future<void> _onLoadDevices(
    LoadDevicesEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    
    try {
      final devices = await _deviceRepository.getDevices();
      emit(DevicesLoaded(devices));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onConnectDevice(
    ConnectDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    
    try {
      final success = await _deviceRepository.connectDevice(event.port);
      
      if (success) {
        final status = await _deviceRepository.getDeviceStatus();
        emit(DeviceConnected(status));
      } else {
        emit(const DeviceError('Failed to connect to device'));
      }
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onDisconnectDevice(
    DisconnectDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());
    
    try {
      final success = await _deviceRepository.disconnectDevice();
      
      if (success) {
        emit(DeviceDisconnected());
      } else {
        emit(const DeviceError('Failed to disconnect device'));
      }
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onRefreshDeviceStatus(
    RefreshDeviceStatusEvent event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      final status = await _deviceRepository.getDeviceStatus();
      emit(DeviceStatusUpdated(status));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onHomeDevice(
    HomeDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await _deviceRepository.homeDevice();
      final status = await _deviceRepository.getDeviceStatus();
      emit(DeviceStatusUpdated(status));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }

  Future<void> _onEmergencyStop(
    EmergencyStopEvent event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await _deviceRepository.emergencyStop();
      final status = await _deviceRepository.getDeviceStatus();
      emit(DeviceStatusUpdated(status));
    } catch (e) {
      emit(DeviceError(e.toString()));
    }
  }
}
