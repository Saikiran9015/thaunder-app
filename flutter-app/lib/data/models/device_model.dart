import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String path;
  final String? manufacturer;
  final String? serialNumber;
  final String? vendorId;
  final String? productId;
  final bool isConnected;

  const DeviceModel({
    required this.path,
    this.manufacturer,
    this.serialNumber,
    this.vendorId,
    this.productId,
    this.isConnected = false,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      path: json['path'] as String,
      manufacturer: json['manufacturer'] as String?,
      serialNumber: json['serialNumber'] as String?,
      vendorId: json['vendorId'] as String?,
      productId: json['productId'] as String?,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'manufacturer': manufacturer,
      'serialNumber': serialNumber,
      'vendorId': vendorId,
      'productId': productId,
      'isConnected': isConnected,
    };
  }

  DeviceModel copyWith({
    String? path,
    String? manufacturer,
    String? serialNumber,
    String? vendorId,
    String? productId,
    bool? isConnected,
  }) {
    return DeviceModel(
      path: path ?? this.path,
      manufacturer: manufacturer ?? this.manufacturer,
      serialNumber: serialNumber ?? this.serialNumber,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [
        path,
        manufacturer,
        serialNumber,
        vendorId,
        productId,
        isConnected,
      ];
}

class DeviceStatus extends Equatable {
  final bool connected;
  final String? port;
  final String status;
  final Position position;
  final bool isHomed;

  const DeviceStatus({
    required this.connected,
    this.port,
    required this.status,
    required this.position,
    required this.isHomed,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      connected: json['connected'] as bool,
      port: json['port'] as String?,
      status: json['status'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      isHomed: json['isHomed'] as bool,
    );
  }

  factory DeviceStatus.initial() {
    return const DeviceStatus(
      connected: false,
      status: 'idle',
      position: Position(x: 0, y: 0),
      isHomed: false,
    );
  }

  @override
  List<Object?> get props => [connected, port, status, position, isHomed];
}

class Position extends Equatable {
  final double x;
  final double y;

  const Position({required this.x, required this.y});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  List<Object?> get props => [x, y];
}
