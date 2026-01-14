import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:safe_labs/core/models/sensor_data.dart';
import 'package:safe_labs/core/services/firebase_sensor_service.dart';
import 'package:safe_labs/desktop/lab_detail_page.dart';

/// Real-time sensor data dashboard widget
/// Displays live data from Wokwi simulators via Firebase Realtime Database
class SensorDashboardWidget extends StatefulWidget {
  const SensorDashboardWidget({super.key});

  @override
  State<SensorDashboardWidget> createState() => _SensorDashboardWidgetState();
}

class _SensorDashboardWidgetState extends State<SensorDashboardWidget> {
  final FirebaseSensorService _sensorService = FirebaseSensorService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SensorData>>(
      stream: _sensorService.getAllLabsDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final labsData = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildLabCards(labsData),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.sensors, color: Colors.blue.shade700, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Sensor Data',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              'Real-time data from Wokwi simulators',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF8A8A8E),
              ),
            ),
          ],
        ),
        const Spacer(),
        StreamBuilder<bool>(
          stream: _sensorService.getConnectionStatusStream(),
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? false;
            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabCards(List<SensorData> labsData) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: labsData.map((data) => _buildLabCard(data)).toList(),
    );
  }

  Widget _buildLabCard(SensorData data) {
    final isOnline = data.isOnline && !data.isStale;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LabDetailPage(deviceId: data.deviceId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isOnline ? Colors.green.shade200 : Colors.red.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabCardHeader(data, isOnline),
            const SizedBox(height: 20),
            _buildSensorMetrics(data, isOnline),
            const SizedBox(height: 15),
            _buildStatusIndicators(data, isOnline),
            if (data.timestamp > 0) ...[
              const SizedBox(height: 15),
              _buildTimestamp(data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabCardHeader(SensorData data, bool isOnline) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.biotech_rounded,
            color: isOnline ? Colors.green.shade700 : Colors.grey.shade400,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.displayName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              Text(
                data.deviceId,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8A8A8E),
                ),
              ),
            ],
          ),
        ),
        _buildOnlineIndicator(isOnline),
      ],
    );
  }

  Widget _buildOnlineIndicator(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorMetrics(SensorData data, bool isOnline) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Temperature',
            isOnline ? '${data.temperature.toStringAsFixed(1)}°C' : '--°C',
            Icons.thermostat,
            Colors.orange,
            isOnline,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricItem(
            'Humidity',
            isOnline ? '${data.humidity.toStringAsFixed(1)}%' : '--%',
            Icons.water_drop,
            Colors.blue,
            isOnline,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildMetricItem(
            'Air Quality',
            isOnline ? '${data.mq135} ppm' : '-- ppm',
            Icons.air,
            Colors.purple,
            isOnline,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
      String label, String value, IconData icon, Color color, bool isOnline) {
    return Column(
      children: [
        Icon(
          icon,
          color: isOnline ? color : Colors.grey.shade300,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isOnline ? const Color(0xFF333333) : Colors.grey.shade400,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF8A8A8E),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(SensorData data, bool isOnline) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusChip(
            'Motion',
            data.motionDetected && isOnline,
            Icons.motion_photos_on,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatusChip(
            'AC',
            data.acStatus && isOnline,
            Icons.ac_unit,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.green.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green.shade700 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(SensorData data) {
    final formattedTime =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(data.dateTime);
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          'Last update: $formattedTime',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF8A8A8E),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error Loading Sensor Data',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
