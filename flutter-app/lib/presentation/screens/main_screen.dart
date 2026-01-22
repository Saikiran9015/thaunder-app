import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/design_bloc/design_bloc.dart';
import '../../business_logic/template_bloc/template_bloc.dart';
import '../widgets/sidebar.dart';
import '../widgets/toolbar.dart';
import '../widgets/design_canvas.dart';
import '../widgets/control_panel.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<DesignBloc, DesignState>(
            listener: (context, state) {
              if (state is DesignError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is DesignUploaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Design uploaded successfully! Drag to move.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          BlocListener<TemplateBloc, TemplateState>(
            listener: (context, state) {
              if (state is TemplateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Row(
          children: [
            // Left Sidebar - Template Selection
            const Sidebar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Toolbar
                  const Toolbar(),

                  // Design Canvas
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8F9FA), // Slightly lighter gray for canvas area
                      child: const DesignCanvas(),
                    ),
                  ),

                  // Bottom Control Panel
                  const ControlPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
