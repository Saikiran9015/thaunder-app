import '../models/device_model.dart';
import '../services/api_service.dart';

class DeviceRepository {
  final ApiService _apiService;

  DeviceRepository(this._apiService);

  Future<List<DeviceModel>> getDevices() async {
    try {
      final response = await _apiService.get('/api/devices');
      
      if (response.data['success'] == true) {
        final List<dynamic> devicesJson = response.data['devices'];
        return devicesJson.map((json) => DeviceModel.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load devices');
    } catch (e) {
      throw Exception('Error fetching devices: $e');
    }
  }

  Future<bool> connectDevice(String port) async {
    try {
      final response = await _apiService.post(
        '/api/devices/connect',
        data: {'port': port},
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error connecting to device: $e');
    }
  }

  Future<bool> disconnectDevice() async {
    try {
      final response = await _apiService.post('/api/devices/disconnect');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error disconnecting device: $e');
    }
  }

  Future<DeviceStatus> getDeviceStatus() async {
    try {
      final response = await _apiService.get('/api/devices/status');
      
      if (response.data['success'] == true) {
        return DeviceStatus.fromJson(response.data['status']);
      }
      
      throw Exception('Failed to get device status');
    } catch (e) {
      throw Exception('Error getting device status: $e');
    }
  }

  Future<bool> homeDevice() async {
    try {
      final response = await _apiService.post('/api/devices/home');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error homing device: $e');
    }
  }

  Future<bool> emergencyStop() async {
    try {
      final response = await _apiService.post('/api/devices/emergency-stop');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error executing emergency stop: $e');
    }
  }
}
