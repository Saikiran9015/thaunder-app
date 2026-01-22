import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/device_bloc/device_bloc.dart';
import '../../core/theme/app_theme.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  double speed = 50.0;
  double pressure = 300.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Device Status Indicator
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              bool isConnected = state is DeviceConnected || state is DeviceStatusUpdated;
              return Row(
                children: [
                  _buildStatusBadge(isConnected),
                  const SizedBox(width: 40),
                ],
              );
            },
          ),

          // Speed Control
          Expanded(
            flex: 2,
            child: _buildControlSlider(
              label: 'Cutting Speed',
              value: speed,
              min: 1,
              max: 100,
              unit: '%',
              onChanged: (val) => setState(() => speed = val),
            ),
          ),

          const SizedBox(width: 40),

          // Pressure Control
          Expanded(
            flex: 2,
            child: _buildControlSlider(
              label: 'Blade Pressure',
              value: pressure,
              min: 10,
              max: 500,
              unit: 'g',
              onChanged: (val) => setState(() => pressure = val),
            ),
          ),

          const SizedBox(width: 40),

          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                onPressed: () => context.read<DeviceBloc>().add(const HomeDeviceEvent()),
                icon: Icons.home_rounded,
                label: 'HOME',
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Job...')),
                  );
                },
                icon: Icons.play_arrow_rounded,
                label: 'START',
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                onPressed: () => context.read<DeviceBloc>().add(const EmergencyStopEvent()),
                icon: Icons.stop_rounded,
                label: 'STOP',
                color: AppTheme.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool connected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: connected ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: connected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            connected ? 'CONNECTED' : 'OFFLINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: connected ? Colors.green.shade700 : Colors.red.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
            Text('${value.toInt()}$unit',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.grey.shade200,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }
}
