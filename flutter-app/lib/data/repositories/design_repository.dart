import '../services/api_service.dart';

class DesignRepository {
  final ApiService _apiService;

  DesignRepository(this._apiService);

  Future<Map<String, dynamic>> uploadDesign(String filePath) async {
    try {
      final response = await _apiService.uploadFile('/api/design/upload', filePath);
      
      if (response.data['success'] == true) {
        return response.data['design'];
      }
      
      throw Exception('Failed to upload design');
    } catch (e) {
      throw Exception('Error uploading design: $e');
    }
  }

  Future<Map<String, dynamic>> processDesign({
    required String filePath,
    double scaleX = 1.0,
    double scaleY = 1.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
    bool mirror = false,
    int speed = 50,
    int pressure = 300,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/design/process',
        data: {
          'filePath': filePath,
          'scaleX': scaleX,
          'scaleY': scaleY,
          'offsetX': offsetX,
          'offsetY': offsetY,
          'mirror': mirror,
          'speed': speed,
          'pressure': pressure,
        },
      );
      
      if (response.data['success'] == true) {
        return {
          'gcode': response.data['gcode'],
          'stats': response.data['stats'],
        };
      }
      
      throw Exception('Failed to process design');
    } catch (e) {
      throw Exception('Error processing design: $e');
    }
  }

  Future<Map<String, dynamic>> getPreview(String filePath) async {
    try {
      final response = await _apiService.post(
        '/api/design/preview',
        data: {'filePath': filePath},
      );
      
      if (response.data['success'] == true) {
        return response.data['preview'];
      }
      
      throw Exception('Failed to get preview');
    } catch (e) {
      throw Exception('Error getting preview: $e');
    }
  }

  Future<bool> startCutting(List<String> gcode, {int? speed, int? pressure}) async {
    try {
      final data = <String, dynamic>{'gcode': gcode};
      if (speed != null) data['speed'] = speed;
      if (pressure != null) data['pressure'] = pressure;

      final response = await _apiService.post('/api/cut/start', data: data);
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error starting cutting: $e');
    }
  }

  Future<bool> pauseCutting() async {
    try {
      final response = await _apiService.post('/api/cut/pause');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error pausing cutting: $e');
    }
  }

  Future<bool> resumeCutting() async {
    try {
      final response = await _apiService.post('/api/cut/resume');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error resuming cutting: $e');
    }
  }

  Future<bool> cancelCutting() async {
    try {
      final response = await _apiService.post('/api/cut/cancel');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error cancelling cutting: $e');
    }
  }
}
