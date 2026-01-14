import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:safe_labs/core/models/sensor_data.dart';
import 'package:safe_labs/core/services/firebase_sensor_service.dart';

/// Detailed view for a single laboratory with real-time sensor data
class LabDetailPage extends StatefulWidget {
  final String deviceId;

  const LabDetailPage({
    super.key,
    required this.deviceId,
  });

  @override
  State<LabDetailPage> createState() => _LabDetailPageState();
}

class _LabDetailPageState extends State<LabDetailPage> {
  final FirebaseSensorService _sensorService = FirebaseSensorService();
  List<SensorData> _historicalData = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    final history = await _sensorService.getHistoricalData(widget.deviceId);
    if (mounted) {
      setState(() {
        _historicalData = history;
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<SensorData>(
          stream: _sensorService.getSensorDataStream(widget.deviceId),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.displayName ?? 'Lab Details',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                Text(
                  widget.deviceId,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A8A8E),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<SensorData>(
        stream: _sensorService.getSensorDataStream(widget.deviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? SensorData.offline(widget.deviceId);
          final isOnline = data.isOnline && !data.isStale;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(data, isOnline),
                const SizedBox(height: 20),
                _buildSensorMetricsCards(data, isOnline),
                const SizedBox(height: 20),
                _buildControlPanel(data),
                const SizedBox(height: 20),
                _buildHistoricalChart(),
                const SizedBox(height: 20),
                _buildEventLog(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(SensorData data, bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.biotech_rounded,
              size: 40,
              color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? Colors.green.shade50
                            : Colors.red.shade50,
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
                              color: isOnline
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.timestamp > 0)
                  Text(
                    'Last update: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(data.dateTime)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF8A8A8E),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorMetricsCards(SensorData data, bool isOnline) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Temperature',
            isOnline ? '${data.temperature.toStringAsFixed(1)}°C' : '--°C',
            Icons.thermostat,
            Colors.orange,
            isOnline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Humidity',
            isOnline ? '${data.humidity.toStringAsFixed(1)}%' : '--%',
            Icons.water_drop,
            Colors.blue,
            isOnline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
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

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color, bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isOnline ? color : Colors.grey.shade300,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOnline ? const Color(0xFF333333) : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8A8A8E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(SensorData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Controls & Status',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildControlItem(
                  'Motion Sensor',
                  data.motionDetected,
                  Icons.motion_photos_on,
                  null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<bool>(
                  stream: _sensorService.getACStatusStream(widget.deviceId),
                  builder: (context, snapshot) {
                    final acStatus = snapshot.data ?? false;
                    return _buildControlItem(
                      'Air Conditioning',
                      acStatus,
                      Icons.ac_unit,
                      () => _toggleAC(!acStatus),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem(
      String label, bool isActive, IconData icon, VoidCallback? onToggle) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.green.shade700 : Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8A8A8E),
                    ),
                  ),
                ],
              ),
            ),
            if (onToggle != null)
              Icon(
                Icons.toggle_on,
                color: isActive ? Colors.green.shade700 : Colors.grey.shade400,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historicalData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No historical data available',
            style: GoogleFonts.inter(
              color: const Color(0xFF8A8A8E),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historical Trends',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _historicalData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value.temperature,
                            ))
                        .toList(),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLog() {
    return StreamBuilder<List<SensorEvent>>(
      stream: _sensorService.getEventsStream(widget.deviceId, limit: 20),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Events',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (events.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No events recorded',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8A8A8E),
                      ),
                    ),
                  ),
                )
              else
                ...events.take(10).map((event) => _buildEventItem(event)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventItem(SensorEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event.type),
            size: 20,
            color: const Color(0xFF8A8A8E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.message,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                Text(
                  DateFormat('MMM dd, HH:mm:ss').format(event.dateTime),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A8A8E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'motion':
        return Icons.motion_photos_on;
      case 'temperature':
        return Icons.thermostat;
      case 'ac':
        return Icons.ac_unit;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _toggleAC(bool newStatus) async {
    try {
      await _sensorService.setACStatus(widget.deviceId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AC turned ${newStatus ? 'ON' : 'OFF'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle AC: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
