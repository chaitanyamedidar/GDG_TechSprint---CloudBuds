import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/core/services/alert_service.dart';
import 'package:safe_labs/core/services/firebase_sensor_service.dart';

/// Alert notification widget - shows in app bar or header
class AlertNotificationWidget extends StatelessWidget {
  const AlertNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = FirebaseSensorService();
    final alertService = AlertService();

    return StreamBuilder<List<LabAlert>>(
      stream:
          alertService.getAllAlertsStream(sensorService.getAllLabsDataStream()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final alerts = snapshot.data!;
        final activeAlertCount = alertService.getActiveAlertCount(alerts);
        final criticalCount = alertService.getCriticalCount(alerts);
        final warningCount = alertService.getWarningCount(alerts);

        return InkWell(
          onTap: () => _showAlertsDialog(context, alerts),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: criticalCount > 0
                  ? Colors.red.shade50
                  : warningCount > 0
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: criticalCount > 0
                    ? Colors.red.shade200
                    : warningCount > 0
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  criticalCount > 0
                      ? Icons.warning_amber_rounded
                      : warningCount > 0
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                  color: criticalCount > 0
                      ? Colors.red.shade700
                      : warningCount > 0
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  activeAlertCount > 0
                      ? '$activeAlertCount Alert${activeAlertCount > 1 ? 's' : ''}'
                      : 'All Systems Safe',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: criticalCount > 0
                        ? Colors.red.shade700
                        : warningCount > 0
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                  ),
                ),
                if (activeAlertCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: criticalCount > 0 ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$activeAlertCount',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertsDialog(BuildContext context, List<LabAlert> alerts) {
    final activeAlerts = alerts
        .where((a) =>
            a.severity == AlertSeverity.critical ||
            a.severity == AlertSeverity.warning ||
            a.severity == AlertSeverity.offline)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Text(
              'Lab Alerts',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: activeAlerts.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'All Labs Operating Normally',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No active alerts or warnings',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = activeAlerts[index];
                    return _buildAlertCard(alert);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(LabAlert alert) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.critical:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
        icon = Icons.dangerous;
        break;
      case AlertSeverity.warning:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange;
        textColor = Colors.orange.shade900;
        icon = Icons.warning_amber;
        break;
      case AlertSeverity.offline:
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey;
        textColor = Colors.grey.shade900;
        icon = Icons.signal_wifi_off;
        break;
      default:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.deviceName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      alert.severityText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alert.messages.map((message) => Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: borderColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
