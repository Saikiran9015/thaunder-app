import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../business_logic/template_bloc/template_bloc.dart';
import '../../business_logic/design_bloc/design_bloc.dart';
import '../../core/theme/app_theme.dart';

class DesignCanvas extends StatefulWidget {
  const DesignCanvas({super.key});

  @override
  State<DesignCanvas> createState() => _DesignCanvasState();
}

class _DesignCanvasState extends State<DesignCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0;
  double _rotationY = 0;
  bool _isAutoRotating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        if (_isAutoRotating) {
          setState(() {
            _rotationY = _controller.value * 2 * 3.14159;
          });
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            BlocBuilder<TemplateBloc, TemplateState>(
              builder: (context, templateState) {
                if (templateState is TemplateSelected) {
                  return BlocBuilder<DesignBloc, DesignState>(
                    builder: (context, designState) {
                      return _buildMainView(context, templateState, designState);
                    },
                  );
                }
                return _buildEmptyState(context);
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  const Text('3D Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isAutoRotating,
                    onChanged: (val) {
                      setState(() {
                        _isAutoRotating = val;
                        if (!val) {
                          _rotationX = 0;
                          _rotationY = 0;
                        } else {
                          _controller.repeat();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, TemplateSelected templateState, DesignState designState) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!_isAutoRotating) {
          setState(() {
            _rotationY += details.delta.dx * 0.01;
            _rotationX -= details.delta.dy * 0.01;
          });
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateX(_rotationX)
                ..rotateY(_rotationY),
              child: _buildCanvasStack(context, templateState, designState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasStack(BuildContext context, TemplateSelected templateState, DesignState designState) {
    final template = templateState.template;
    
    return Container(
      width: 320,
      height: 520,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade100],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(10, 10),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(200),
            blurRadius: 20,
            offset: const Offset(-10, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Device body/sides effect
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade300, width: 8),
            ),
          ),
          // Inner Screen
          Center(
            child: Container(
              width: 300,
              height: 500,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Grid Background
                  CustomPaint(
                    size: const Size(300, 500),
                    painter: GridPainter(),
                  ),
                  // Template Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 80,
                          color: Colors.grey.shade100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade300,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Design Layer
                  if (designState is DesignUploaded)
                    _buildDesignLayer(context, designState),

                  // Cutout indicators
                  ...template.cutouts.map((cutout) {
                    return Positioned(
                      left: cutout.x,
                      top: cutout.y,
                      child: Container(
                        width: cutout.width,
                        height: cutout.height,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(10),
                          border: Border.all(
                            color: AppTheme.accentColor.withAlpha(180),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignLayer(BuildContext context, DesignUploaded state) {
    final filePath = state.designInfo['filePath'];
    final isSvg = filePath != null && filePath.toString().toLowerCase().endsWith('.svg');

    return Positioned(
      left: 150 + state.dx - (150 * state.scale / 2),
      top: 250 + state.dy - (150 * state.scale / 2),
      child: GestureDetector(
        onScaleUpdate: (details) {
          if (details.pointerCount == 1) {
            context.read<DesignBloc>().add(UpdateTransformEvent(
                  dx: details.focalPointDelta.dx,
                  dy: details.focalPointDelta.dy,
                ));
          } else if (details.pointerCount == 2) {
            context.read<DesignBloc>().add(UpdateTransformEvent(
                  scale: details.scale,
                ));
          }
        },
        child: Transform.rotate(
          angle: state.rotation,
          child: Container(
            width: 150 * state.scale,
            height: 150 * state.scale,
            child: isSvg
                ? SvgPicture.file(File(filePath), fit: BoxFit.contain)
                : Image.file(File(filePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Select a template to begin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from ${ALL_BRANDS_COUNT}+ brands',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

const int ALL_BRANDS_COUNT = 150;

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
