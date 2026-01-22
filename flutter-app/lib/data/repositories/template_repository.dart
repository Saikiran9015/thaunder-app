import '../models/template_model.dart';
import '../services/api_service.dart';

class TemplateRepository {
  final ApiService _apiService;

  TemplateRepository(this._apiService);

  Future<List<TemplateModel>> getTemplates({String? category, String? brand}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (brand != null) queryParams['brand'] = brand;

      final response = await _apiService.get(
        '/api/templates',
        queryParameters: queryParams,
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> templatesJson = response.data['templates'];
        return templatesJson.map((json) => TemplateModel.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load templates');
    } catch (e) {
      throw Exception('Error fetching templates: $e');
    }
  }

  Future<TemplateModel> getTemplateById(String id) async {
    try {
      final response = await _apiService.get('/api/templates/$id');
      
      if (response.data['success'] == true) {
        return TemplateModel.fromJson(response.data['template']);
      }
      
      throw Exception('Failed to load template');
    } catch (e) {
      throw Exception('Error fetching template: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiService.get('/api/templates/meta/categories');
      
      if (response.data['success'] == true) {
        final List<dynamic> categories = response.data['categories'];
        return categories.map((c) => c['id'] as String).toList();
      }
      
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<String>> getBrands() async {
    try {
      final response = await _apiService.get('/api/templates/meta/brands');
      
      if (response.data['success'] == true) {
        final List<dynamic> brands = response.data['brands'];
        return brands.map((b) => b as String).toList();
      }
      
      throw Exception('Failed to load brands');
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }
}
