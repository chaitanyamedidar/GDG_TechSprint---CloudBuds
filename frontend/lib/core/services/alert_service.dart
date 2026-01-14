import 'package:firebase_database/firebase_database.dart';
import 'package:safe_labs/core/models/sensor_data.dart';

/// Alert severity levels matching dashboard.py logic
enum AlertSeverity { safe, warning, critical, offline }

/// Alert model
class LabAlert {
  final String deviceId;
  final AlertSeverity severity;
  final List<String> messages;
  final DateTime timestamp;

  LabAlert({
    required this.deviceId,
    required this.severity,
    required this.messages,
    required this.timestamp,
  });

  String get deviceName {
    switch (deviceId) {
      case 'sensor_node_01':
        return 'Computer Lab A';
      case 'sensor_node_02':
        return 'Server Room B';
      case 'sensor_node_03':
        return 'Research Lab C';
      default:
        return deviceId;
    }
  }

  String get severityText {
    switch (severity) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.warning:
        return 'WARNING';
      case AlertSeverity.offline:
        return 'OFFLINE';
      case AlertSeverity.safe:
        return 'SAFE';
    }
  }
}

/// Alert Service - Analyzes sensor data and generates alerts
/// Matches the logic from dashboard.py analyze_data function
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  /// Analyze sensor data and return alert (matches dashboard.py logic)
  LabAlert analyzeSensorData(SensorData data) {
    // Check if sensor is online
    if (!data.isOnline || data.isStale) {
      return LabAlert(
        deviceId: data.deviceId,
        severity: AlertSeverity.offline,
        messages: ['Sensor not responding - simulator may be stopped'],
        timestamp: DateTime.now(),
      );
    }

    final temp = data.temperature;
    final humidity = data.humidity;
    final gasPpm = data.mq135;

    final List<String> criticalIssues = [];
    final List<String> warnings = [];

    // Critical conditions (from dashboard.py)
    if (temp > 30 || temp < 10) {
      criticalIssues.add('Critical Temperature: ${temp.toStringAsFixed(1)}°C');
    } else if (temp > 26 || temp < 18) {
      warnings.add('Temperature Warning: ${temp.toStringAsFixed(1)}°C');
    }

    if (humidity > 70 || humidity < 20) {
      criticalIssues.add('Critical Humidity: ${humidity.toStringAsFixed(1)}%');
    } else if (humidity > 60 || humidity < 30) {
      warnings.add('Humidity Warning: ${humidity.toStringAsFixed(1)}%');
    }

    if (gasPpm > 800) {
      criticalIssues.add('Dangerous Gas Level: $gasPpm ppm');
    } else if (gasPpm > 500) {
      warnings.add('Elevated Gas Level: $gasPpm ppm');
    }

    // Determine overall severity
    if (criticalIssues.isNotEmpty) {
      return LabAlert(
        deviceId: data.deviceId,
        severity: AlertSeverity.critical,
        messages: criticalIssues,
        timestamp: DateTime.now(),
      );
    } else if (warnings.isNotEmpty) {
      return LabAlert(
        deviceId: data.deviceId,
        severity: AlertSeverity.warning,
        messages: warnings,
        timestamp: DateTime.now(),
      );
    } else {
      return LabAlert(
        deviceId: data.deviceId,
        severity: AlertSeverity.safe,
        messages: ['All parameters within safe range'],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Get all alerts from current sensor data
  Stream<List<LabAlert>> getAllAlertsStream(
      Stream<List<SensorData>> sensorDataStream) {
    return sensorDataStream.map((dataList) {
      return dataList.map((data) => analyzeSensorData(data)).toList();
    });
  }

  /// Get count of critical alerts
  int getCriticalCount(List<LabAlert> alerts) {
    return alerts.where((a) => a.severity == AlertSeverity.critical).length;
  }

  /// Get count of warning alerts
  int getWarningCount(List<LabAlert> alerts) {
    return alerts.where((a) => a.severity == AlertSeverity.warning).length;
  }

  /// Get count of active alerts (critical + warning)
  int getActiveAlertCount(List<LabAlert> alerts) {
    return alerts
        .where((a) =>
            a.severity == AlertSeverity.critical ||
            a.severity == AlertSeverity.warning)
        .length;
  }
}
