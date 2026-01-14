/// Sensor data model matching Firebase Realtime Database structure
/// Corresponds to /devices/{sensor_node_id}/latest
class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final int mq135;
  final bool motionDetected;
  final bool acStatus;
  final int timestamp;
  final bool isOnline;
  final double avgTemp;
  final double avgHumidity;

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.mq135,
    required this.motionDetected,
    required this.acStatus,
    required this.timestamp,
    this.isOnline = true,
    this.avgTemp = 0.0,
    this.avgHumidity = 0.0,
  });

  /// Create SensorData from Firebase snapshot
  factory SensorData.fromFirebase(String deviceId, Map<dynamic, dynamic> data) {
    return SensorData(
      deviceId: deviceId,
      temperature: (data['temperature'] ?? 0).toDouble(),
      humidity: (data['humidity'] ?? 0).toDouble(),
      mq135: (data['gas_ppm'] ?? data['mq135'] ?? 0).toInt(),
      motionDetected: data['motion_detected'] == 1 ||
          data['motion_detected'] == true ||
          data['motion'] == 1 ||
          data['motion'] == true,
      acStatus: data['ac'] == 1 || data['ac'] == true,
      timestamp: data['timestamp'] ?? 0,
      isOnline: true,
      avgTemp: (data['avg_temp_1h'] ?? 0).toDouble(),
      avgHumidity: (data['avg_hum_1h'] ?? 0).toDouble(),
    );
  }

  /// Create offline/empty sensor data
  factory SensorData.offline(String deviceId) {
    return SensorData(
      deviceId: deviceId,
      temperature: 0.0,
      humidity: 0.0,
      mq135: 0,
      motionDetected: false,
      acStatus: false,
      timestamp: 0,
      isOnline: false,
    );
  }

  /// Check if data is stale (older than 30 seconds)
  bool get isStale {
    // If timestamp is less than 1 billion, it's likely a boot timestamp (millis/1000)
    // not a Unix timestamp, so we can't reliably check staleness
    if (timestamp < 1000000000) {
      // For boot timestamps, consider data fresh (simulator is running)
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - timestamp) > 30;
  }

  /// Get formatted timestamp
  DateTime get dateTime {
    // If timestamp is very small (< 1 billion), it's boot time in seconds
    // Return current time as we can't determine absolute time
    if (timestamp < 1000000000) {
      return DateTime.now();
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// Get display name for device
  String get displayName {
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

  @override
  String toString() {
    return 'SensorData(device: $deviceId, temp: $temperature°C, humidity: $humidity%, mq135: $mq135, motion: $motionDetected, ac: $acStatus, online: $isOnline)';
  }
}

/// Event log model matching Firebase /events structure
class SensorEvent {
  final String deviceId;
  final String type;
  final String message;
  final int timestamp;

  SensorEvent({
    required this.deviceId,
    required this.type,
    required this.message,
    required this.timestamp,
  });

  factory SensorEvent.fromFirebase(
      String deviceId, Map<dynamic, dynamic> data) {
    return SensorEvent(
      deviceId: deviceId,
      type: data['type'] ?? 'unknown',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? 0,
    );
  }

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
