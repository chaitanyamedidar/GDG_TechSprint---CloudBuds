import 'package:firebase_database/firebase_database.dart';
import 'package:safe_labs/core/models/sensor_data.dart';

/// Service for fetching real-time sensor data from Firebase Realtime Database
/// Connects to the Wokwi simulator data at /devices/{sensor_node_id}/latest
class FirebaseSensorService {
  static final FirebaseSensorService _instance =
      FirebaseSensorService._internal();
  factory FirebaseSensorService() => _instance;
  FirebaseSensorService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// List of all lab device IDs
  static const List<String> labDeviceIds = [
    'sensor_node_01',
    'sensor_node_02',
    'sensor_node_03',
  ];

  /// Get real-time stream for a specific lab's sensor data
  /// Path: /devices/{deviceId}/latest
  Stream<SensorData> getSensorDataStream(String deviceId) {
    return _database
        .child('devices')
        .child(deviceId)
        .child('latest')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return SensorData.offline(deviceId);
      }

      try {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        print('📊 Firebase data for $deviceId: $data');
        return SensorData.fromFirebase(deviceId, data);
      } catch (e) {
        print('Error parsing sensor data for $deviceId: $e');
        return SensorData.offline(deviceId);
      }
    });
  }

  /// Get real-time stream for all labs
  Stream<List<SensorData>> getAllLabsDataStream() {
    return _database.child('devices').onValue.map((event) {
      final List<SensorData> allData = [];

      for (final deviceId in labDeviceIds) {
        try {
          final snapshot = event.snapshot.child(deviceId).child('latest');
          if (snapshot.value != null) {
            final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
            print('📊 All labs - data for $deviceId: $data');
            allData.add(SensorData.fromFirebase(deviceId, data));
          } else {
            print('⚠️ No data for $deviceId');
            allData.add(SensorData.offline(deviceId));
          }
        } catch (e) {
          print('Error parsing data for $deviceId: $e');
          allData.add(SensorData.offline(deviceId));
        }
      }

      return allData;
    });
  }

  /// Get one-time snapshot of sensor data
  Future<SensorData> getSensorDataOnce(String deviceId) async {
    try {
      final snapshot = await _database
          .child('devices')
          .child(deviceId)
          .child('latest')
          .get();

      if (snapshot.value == null) {
        return SensorData.offline(deviceId);
      }

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return SensorData.fromFirebase(deviceId, data);
    } catch (e) {
      print('Error fetching sensor data for $deviceId: $e');
      return SensorData.offline(deviceId);
    }
  }

  /// Get AC status stream for a specific lab
  /// Path: /labs/{deviceId}/ac
  Stream<bool> getACStatusStream(String deviceId) {
    return _database
        .child('labs')
        .child(deviceId)
        .child('ac')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return false;
      return event.snapshot.value == 1 || event.snapshot.value == true;
    });
  }

  /// Control AC status (turn on/off)
  Future<void> setACStatus(String deviceId, bool status) async {
    try {
      await _database
          .child('labs')
          .child(deviceId)
          .child('ac')
          .set(status ? 1 : 0);
    } catch (e) {
      print('Error setting AC status for $deviceId: $e');
      rethrow;
    }
  }

  /// Get recent events stream for a specific lab
  /// Path: /events/{deviceId}
  Stream<List<SensorEvent>> getEventsStream(String deviceId, {int limit = 50}) {
    return _database
        .child('events')
        .child(deviceId)
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <SensorEvent>[];

      final List<SensorEvent> events = [];
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      data.forEach((key, value) {
        if (value is Map) {
          events.add(SensorEvent.fromFirebase(
            deviceId,
            Map<dynamic, dynamic>.from(value),
          ));
        }
      });

      // Sort by timestamp descending (newest first)
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    });
  }

  /// Get historical data for a specific lab
  /// Path: /devices/{deviceId}/history
  Future<List<SensorData>> getHistoricalData(String deviceId,
      {int limit = 100}) async {
    try {
      final snapshot = await _database
          .child('devices')
          .child(deviceId)
          .child('history')
          .orderByChild('timestamp')
          .limitToLast(limit)
          .get();

      if (snapshot.value == null) return [];

      final List<SensorData> history = [];
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
        if (value is Map) {
          history.add(SensorData.fromFirebase(
            deviceId,
            Map<dynamic, dynamic>.from(value),
          ));
        }
      });

      // Sort by timestamp ascending (oldest first)
      history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return history;
    } catch (e) {
      print('Error fetching historical data for $deviceId: $e');
      return [];
    }
  }

  /// Check if database connection is working
  Future<bool> testConnection() async {
    try {
      await _database.child('.info/connected').get();
      return true;
    } catch (e) {
      print('Database connection test failed: $e');
      return false;
    }
  }

  /// Listen to connection status
  Stream<bool> getConnectionStatusStream() {
    return _database
        .child('.info/connected')
        .onValue
        .map((event) => event.snapshot.value == true);
  }
}
