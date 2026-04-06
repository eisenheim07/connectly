import 'package:flutter/material.dart';
import '../services/network_resilience_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ReconnectionBanner extends StatelessWidget {
  final NetworkConnectionState connectionState;

  const ReconnectionBanner({super.key, required this.connectionState});

  @override
  Widget build(BuildContext context) {
    if (connectionState == NetworkConnectionState.connected) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _getIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(_getMessage(), style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          if (connectionState == NetworkConnectionState.reconnecting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (connectionState) {
      case NetworkConnectionState.disconnected:
        return Colors.red.shade700;
      case NetworkConnectionState.reconnecting:
        return Colors.orange.shade700;
      case NetworkConnectionState.poor:
        return Colors.yellow.shade700;
      case NetworkConnectionState.connected:
        return Colors.green.shade700;
    }
  }

  Widget _getIcon() {
    IconData iconData;
    switch (connectionState) {
      case NetworkConnectionState.disconnected:
        iconData = Icons.wifi_off;
        break;
      case NetworkConnectionState.reconnecting:
        iconData = Icons.sync;
        break;
      case NetworkConnectionState.poor:
        iconData = Icons.signal_wifi_bad;
        break;
      case NetworkConnectionState.connected:
        iconData = Icons.wifi;
        break;
    }

    return Icon(iconData, color: Colors.white, size: 24);
  }

  String _getTitle() {
    switch (connectionState) {
      case NetworkConnectionState.disconnected:
        return 'Connection Lost';
      case NetworkConnectionState.reconnecting:
        return 'Reconnecting...';
      case NetworkConnectionState.poor:
        return 'Poor Connection';
      case NetworkConnectionState.connected:
        return 'Connected';
    }
  }

  String _getMessage() {
    switch (connectionState) {
      case NetworkConnectionState.disconnected:
        return 'Unable to connect to the meeting';
      case NetworkConnectionState.reconnecting:
        return 'Attempting to restore connection';
      case NetworkConnectionState.poor:
        return 'Video quality may be affected';
      case NetworkConnectionState.connected:
        return 'Connection restored';
    }
  }
}
