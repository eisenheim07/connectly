import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/event_logger.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';

class EventLogScreen extends StatefulWidget {
  const EventLogScreen({super.key});

  @override
  State<EventLogScreen> createState() => _EventLogScreenState();
}

class _EventLogScreenState extends State<EventLogScreen> {
  final EventLogger _logger = EventLogger();
  List<ChimeEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _logger.addListener(_onNewEvent);
  }

  @override
  void dispose() {
    _logger.removeListener(_onNewEvent);
    super.dispose();
  }

  void _onNewEvent(ChimeEvent event) {
    if (mounted) {
      setState(() {
        _events = _logger.events;
      });
    }
  }

  void _loadEvents() {
    setState(() {
      _events = _logger.events;
    });
  }

  void _exportLogs() {
    final json = jsonEncode(_logger.exportEvents());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _clearLogs() {
    _logger.clear();
    setState(() {
      _events = [];
    });
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return AppColors.red;
      case ErrorSeverity.high:
        return AppColors.orange;
      case ErrorSeverity.medium:
        return AppColors.yellow;
      case ErrorSeverity.low:
        return AppColors.blue;
      case ErrorSeverity.info:
        return AppColors.grey;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meetingCreated:
      case EventType.meetingJoined:
        return Icons.video_call;
      case EventType.meetingLeft:
        return Icons.call_end;
      case EventType.videoStarted:
        return Icons.videocam;
      case EventType.videoStopped:
        return Icons.videocam_off;
      case EventType.audioMuted:
        return Icons.mic_off;
      case EventType.audioUnmuted:
        return Icons.mic;
      case EventType.networkLost:
        return Icons.wifi_off;
      case EventType.networkRecovered:
        return Icons.wifi;
      case EventType.reconnecting:
        return Icons.sync;
      case EventType.reconnected:
        return Icons.check_circle;
      case EventType.error:
        return Icons.error;
      case EventType.warning:
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Event Logs (${_events.length}/50)',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportLogs,
            tooltip: 'Export Logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: _events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No events logged yet', style: AppTypography.bodyMediumSecondary()),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              reverse: true,
              itemBuilder: (context, index) {
                final event = _events[_events.length - 1 - index];
                return _buildEventCard(event);
              },
            ),
    );
  }

  Widget _buildEventCard(ChimeEvent event) {
    return Card(
      color: AppColors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getEventIcon(event.type),
          color: _getSeverityColor(event.severity),
        ),
        title: Text(
          event.message,
          style: AppTypography.bodyMediumSemiBold(),
        ),
        subtitle: Text(
          '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}.${event.timestamp.millisecond.toString().padLeft(3, '0')}',
          style: AppTypography.bodySmallSecondary(),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', event.type.name),
                _buildDetailRow('Severity', event.severity.name.toUpperCase()),
                _buildDetailRow('Timestamp', event.timestamp.toIso8601String()),
                if (event.metadata != null && event.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Metadata:', style: AppTypography.bodySmallBold()),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jsonEncode(event.metadata),
                      style: AppTypography.bodySmall(fontFamily: 'monospace'),
                    ),
                  ),
                ],
                if (event.stackTrace != null) ...[
                  const SizedBox(height: 8),
                  Text('Stack Trace:', style: AppTypography.bodySmallBold()),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.stackTrace!,
                      style: AppTypography.bodySmall(fontFamily: 'monospace'),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: AppTypography.bodySmallBold()),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodySmall()),
          ),
        ],
      ),
    );
  }
}
