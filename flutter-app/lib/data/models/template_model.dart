import 'package:equatable/equatable.dart';

class TemplateModel extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String category;
  final Dimensions dimensions;
  final List<Cutout> cutouts;
  final String? svgPath;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.dimensions,
    required this.cutouts,
    this.svgPath,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      dimensions: Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      cutouts: (json['cutouts'] as List<dynamic>)
          .map((e) => Cutout.fromJson(e as Map<String, dynamic>))
          .toList(),
      svgPath: json['svgPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'dimensions': dimensions.toJson(),
      'cutouts': cutouts.map((e) => e.toJson()).toList(),
      'svgPath': svgPath,
    };
  }

  @override
  List<Object?> get props => [id, name, brand, category, dimensions, cutouts, svgPath];
}

class Dimensions extends Equatable {
  final double width;
  final double height;

  const Dimensions({required this.width, required this.height});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  @override
  List<Object?> get props => [width, height];
}

class Cutout extends Equatable {
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;

  const Cutout({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory Cutout.fromJson(Map<String, dynamic> json) {
    return Cutout(
      type: json['type'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  @override
  List<Object?> get props => [type, x, y, width, height];
}
