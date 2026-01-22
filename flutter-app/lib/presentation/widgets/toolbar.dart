import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/design_bloc/design_bloc.dart';
import '../../business_logic/template_bloc/template_bloc.dart';
import '../../data/services/printing_service.dart';
import '../../core/theme/app_theme.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 24),
            _buildToolButton(
              context,
              icon: Icons.upload_file,
              label: 'Upload Images',
              onTap: () => _handleFileUpload(context),
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.edit,
              label: 'Edit Model',
              onTap: () => _showEditDialog(context),
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.font_download,
              label: 'Font Style',
              onTap: () => _showFontDialog(context),
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.layers,
              label: 'Uploading Template',
              onTap: () => _handleTemplateUpload(context),
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.restart_alt,
              label: 'Reset Design',
              onTap: () {
                context.read<DesignBloc>().add(const ResetDesignEvent());
              },
            ),
            const Spacer(),
            _buildToolButton(
              context,
              icon: Icons.output,
              label: 'Output',
              onTap: () {},
              isPrimary: true,
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.print,
              label: 'Print (Xerox)',
              onTap: () => _handlePrint(context),
              isPrimary: true,
            ),
            const SizedBox(width: 8),
            _buildToolButton(
              context,
              icon: Icons.content_cut,
              label: 'Cutting Machine',
              onTap: () {
                // Trigger cutting logic
                final state = context.read<DesignBloc>().state;
                if (state is DesignUploaded) {
                  // In a real app, process to G-code first
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Cutting Job...')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload a design first')),
                  );
                }
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isPrimary ? Colors.white : AppTheme.textPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final designState = context.read<DesignBloc>().state;
    if (designState is! DesignUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a design first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Design Transform'),
        content: BlocBuilder<DesignBloc, DesignState>(
          builder: (context, state) {
            if (state is! DesignUploaded) return const SizedBox.shrink();
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Scale'),
                    Text('${state.scale.toStringAsFixed(2)}x'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        context.read<DesignBloc>().add(UpdateTransformEvent(scale: 0.9));
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: state.scale,
                        min: 0.1,
                        max: 5.0,
                        onChanged: (val) {
                          context.read<DesignBloc>().add(UpdateTransformEvent(scale: val / state.scale));
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        context.read<DesignBloc>().add(UpdateTransformEvent(scale: 1.1));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rotation'),
                    Text('${(state.rotation * 180 / 3.14159).toStringAsFixed(0)}°'),
                  ],
                ),
                Slider(
                  value: state.rotation,
                  min: -3.14159,
                  max: 3.14159,
                  onChanged: (val) {
                    context.read<DesignBloc>().add(UpdateTransformEvent(rotation: val - state.rotation));
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<DesignBloc>().add(const ResetDesignEvent());
              Navigator.pop(context);
            },
            child: const Text('Reset All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFontDialog(BuildContext context) async {
    // Placeholder for Font Style functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text Design'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter text here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              isExpanded: true,
              value: 'Arial',
              items: ['Arial', 'Roboto', 'Inter', 'Serif']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Text design added (Simulated)')),
              );
              Navigator.pop(context);
            },
            child: const Text('Add to Canvas'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTemplateUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg', 'dxf'],
    );

    if (result != null && result.files.single.path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template uploaded: ${result.files.single.name}')),
      );
      // In a real app, this would trigger a TemplateBloc event to add a custom template
    }
  }

  Future<void> _handleFileUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<DesignBloc>().add(
              UploadDesignEvent(result.files.single.path!),
            );
      }
    }
  }

  Future<void> _handlePrint(BuildContext context) async {
    final templateState = context.read<TemplateBloc>().state;
    final designState = context.read<DesignBloc>().state;

    String templateName = 'Unknown';
    if (templateState is TemplateSelected) {
      templateName = templateState.template.name;
    }

    String? imagePath;
    if (designState is DesignUploaded) {
      imagePath = designState.designInfo['filePath'];
    }

    await PrintingService.printDesign(
      title: 'ThunderCut_Job_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      templateName: templateName,
    );
  }
}

