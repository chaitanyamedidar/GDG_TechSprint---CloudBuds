import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/core/models/sensor_data.dart';
import 'package:safe_labs/core/services/firebase_sensor_service.dart';
import 'package:safe_labs/core/services/alert_service.dart';
import 'package:safe_labs/core/widgets/alert_notification_widget.dart';
import 'package:safe_labs/desktop/lab_detail_page.dart';

// --- COLORS & STYLES ---
const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);
const Color _safeColor = Color(0xFF6FCF97);
const Color _alertColor = Color(0xFFEB5757);

// --- DATA MODEL ---
enum LabStatus { safe, overheating, offline, leak_detected }

class LabInfo {
  final String department;
  final String name;
  final LabStatus status;
  final String? temperature;
  final String? occupancy;
  final String? load;
  final String? airQuality;
  final String? lockStatus;
  final String? lastSeen;
  final String? maintenanceNote;
  final String imagePath;
  final String? deviceId; // Add device ID for Firebase labs

  LabInfo({
    required this.department,
    required this.name,
    required this.status,
    required this.imagePath,
    this.temperature,
    this.occupancy,
    this.load,
    this.airQuality,
    this.lockStatus,
    this.lastSeen,
    this.maintenanceNote,
    this.deviceId, // Optional device ID
  });
}

// --- PAGE WIDGET ---
class AllLaboratoriesPage extends StatefulWidget {
  const AllLaboratoriesPage({super.key});

  @override
  _AllLaboratoriesPageState createState() => _AllLaboratoriesPageState();
}

class _AllLaboratoriesPageState extends State<AllLaboratoriesPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int _currentPage = 1;
  final FirebaseSensorService _sensorService = FirebaseSensorService();
  final AlertService _alertService = AlertService();

  // Store sensor data for Firebase labs
  Map<String, SensorData> _sensorDataMap = {};
  List<LabAlert> _currentAlerts = [];

  // Placeholder labs (keep as static data)
  final List<LabInfo> _placeholderLabs = [
    LabInfo(
        department: 'BIOLOGY DEPT',
        name: 'Bio Lab 04',
        status: LabStatus.offline,
        imagePath: '',
        lastSeen: '4h ago',
        maintenanceNote: 'System disconnected unexpectedly.'),
    LabInfo(
        department: 'PHYSICS DEPT',
        name: 'Physics Lab 05',
        status: LabStatus.safe,
        imagePath: 'https://placehold.co/400x300/F5F5F5/000000?text=Lab+05',
        temperature: '23°C',
        occupancy: 'Occupied'),
    LabInfo(
        department: 'CHEMISTRY DEPT',
        name: 'Organic Lab 2',
        status: LabStatus.safe,
        imagePath: 'https://placehold.co/400x300/F5F5F5/000000?text=Lab+2',
        temperature: '23°C',
        occupancy: 'Occupied'),
    LabInfo(
        department: 'STORAGE',
        name: 'Chemical Vault',
        status: LabStatus.leak_detected,
        imagePath: 'https://placehold.co/400x300/757575/FFFFFF?text=Vault',
        airQuality: 'CRITICAL',
        lockStatus: 'Engaged'),
    LabInfo(
        department: 'ROBOTICS',
        name: 'Assembly Area 1',
        status: LabStatus.safe,
        imagePath: 'https://placehold.co/400x300/9E9E9E/FFFFFF?text=Robotics',
        temperature: '20°C',
        occupancy: 'Empty'),
    LabInfo(
        department: 'GENERAL SCI',
        name: 'Lab Annex 3',
        status: LabStatus.offline,
        imagePath: '',
        lastSeen: '2d ago',
        maintenanceNote: 'Maintenance scheduled.'),
  ];

  List<LabInfo> _filteredLabs = [];
  List<LabInfo> _allLabs = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        // Just trigger rebuild, filtering happens in build
      });
    });
    _filteredLabs = List.from(_placeholderLabs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Convert Firebase sensor data to LabInfo
  LabInfo _sensorDataToLabInfo(SensorData data) {
    final isOnline = data.isOnline && !data.isStale;

    // Determine status based on sensor readings
    LabStatus status;
    if (!isOnline) {
      status = LabStatus.offline;
    } else if (data.temperature > 30 || data.mq135 > 800) {
      status = LabStatus.overheating;
    } else {
      status = LabStatus.safe;
    }

    // Get department name based on device ID
    String department;
    String imagePath;
    switch (data.deviceId) {
      case 'sensor_node_01':
        department = 'COMPUTER SCIENCE';
        imagePath =
            'https://placehold.co/400x300/E0E0E0/000000?text=Computer+Lab+A';
        break;
      case 'sensor_node_02':
        department = 'IT INFRASTRUCTURE';
        imagePath =
            'https://placehold.co/400x300/333333/FFFFFF?text=Server+Room+B';
        break;
      case 'sensor_node_03':
        department = 'RESEARCH & DEVELOPMENT';
        imagePath =
            'https://placehold.co/400x300/424242/FFFFFF?text=Research+Lab+C';
        break;
      default:
        department = 'UNKNOWN';
        imagePath =
            'https://placehold.co/400x300/CCCCCC/000000?text=Unknown+Lab';
    }

    return LabInfo(
      department: department,
      name: data.deviceId.replaceAll('_', ' ').toUpperCase(),
      status: status,
      imagePath: imagePath,
      temperature: isOnline ? '${data.temperature.toStringAsFixed(1)}°C' : null,
      occupancy: isOnline ? (data.motionDetected ? 'Occupied' : 'Empty') : null,
      load: isOnline && data.temperature > 28 ? 'High Usage' : null,
      airQuality: isOnline && data.mq135 > 500 ? '${data.mq135} ppm' : null,
      lastSeen: !isOnline ? 'Offline' : null,
      maintenanceNote: !isOnline ? 'Sensor not responding' : null,
      deviceId: data.deviceId, // Store device ID for mapping
    );
  }

  /// Combine Firebase data with placeholder data
  List<LabInfo> _getAllLabs(List<SensorData> sensorData) {
    // Create a map for quick lookup
    _sensorDataMap = {};
    for (var data in sensorData) {
      _sensorDataMap[data.deviceId] = data;
    }

    final firebaseLabs =
        sensorData.map((data) => _sensorDataToLabInfo(data)).toList();
    return [...firebaseLabs, ..._placeholderLabs];
  }

  List<LabInfo> _getFilteredLabs(List<LabInfo> allLabs) {
    final searchText = _searchController.text.toLowerCase();
    return allLabs.where((lab) {
      // Search filter
      final matchesSearch = searchText.isEmpty ||
          lab.name.toLowerCase().contains(searchText) ||
          lab.department.toLowerCase().contains(searchText);

      if (!matchesSearch) return false;

      // Chip filter - use alert data if available
      final labAlert = lab.deviceId != null
          ? _currentAlerts.firstWhere(
              (a) => a.deviceId == lab.deviceId,
              orElse: () => LabAlert(
                deviceId: lab.deviceId!,
                severity: AlertSeverity.safe,
                messages: [],
                timestamp: DateTime.now(),
              ),
            )
          : null;

      switch (_selectedFilter) {
        case 'Alerts':
          if (labAlert != null) {
            return labAlert.severity == AlertSeverity.critical ||
                labAlert.severity == AlertSeverity.warning;
          }
          return lab.status == LabStatus.overheating ||
              lab.status == LabStatus.leak_detected;
        case 'Online':
          if (labAlert != null) {
            return labAlert.severity == AlertSeverity.safe;
          }
          return lab.status == LabStatus.safe;
        case 'Offline':
          if (labAlert != null) {
            return labAlert.severity == AlertSeverity.offline;
          }
          return lab.status == LabStatus.offline;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SensorData>>(
      stream: _sensorService.getAllLabsDataStream(),
      builder: (context, snapshot) {
        // Get all labs (Firebase + placeholders)
        _allLabs =
            snapshot.hasData ? _getAllLabs(snapshot.data!) : _placeholderLabs;

        // Generate alerts from sensor data
        if (snapshot.hasData) {
          _currentAlerts = snapshot.data!
              .map((data) => _alertService.analyzeSensorData(data))
              .toList();
        }

        // Calculate filtered labs without setState
        _filteredLabs = _getFilteredLabs(_allLabs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildFilters(_allLabs),
            const SizedBox(height: 30),
            _buildLabGrid(),
            const SizedBox(height: 30),
            _buildPagination(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    final activeAlertCount = _alertService.getActiveAlertCount(_currentAlerts);

    return Row(
      children: [
        Text('All Laboratories',
            style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(width: 20),
        Text('${_filteredLabs.length} Total',
            style: GoogleFonts.inter(color: _subTextColor, fontSize: 16)),
        const SizedBox(width: 5),
        const Text('•', style: TextStyle(color: _alertColor)),
        const SizedBox(width: 5),
        Text('$activeAlertCount Alert${activeAlertCount != 1 ? 's' : ''}',
            style: GoogleFonts.inter(
                color: _alertColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        const AlertNotificationWidget(),
      ],
    );
  }

  Widget _buildFilters(List<LabInfo> allLabs) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Lab ID or Dept...',
              prefixIcon: const Icon(Icons.search, color: _subTextColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 20),
        _buildFilterChip('All', false, false),
        _buildFilterChip('Alerts', true, false),
        _buildFilterChip('Online', false, true),
        _buildFilterChip('Offline', false, false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isAlert, bool isOnline) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedFilter = label;
            }
          });
        },
        backgroundColor: Colors.white,
        selectedColor: isAlert
            ? _alertColor.withOpacity(0.1)
            : (isOnline ? _safeColor.withOpacity(0.1) : Colors.black),
        labelStyle: TextStyle(
            color: isSelected
                ? (isAlert
                    ? _alertColor
                    : (isOnline ? _safeColor : Colors.white))
                : _textColor,
            fontWeight: FontWeight.bold),
        avatar: isAlert
            ? const Icon(Icons.error_outline, color: _alertColor, size: 16)
            : (isOnline
                ? const Icon(Icons.check_circle_outline,
                    color: _safeColor, size: 16)
                : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildLabGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredLabs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      itemBuilder: (context, index) {
        final lab = _filteredLabs[index];
        // Get sensor data if this is a Firebase lab
        final sensorData =
            lab.deviceId != null ? _sensorDataMap[lab.deviceId] : null;
        return _LabCard(lab: lab, sensorData: sensorData);
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageNumber(1, true),
        _buildPageNumber(2, false),
        _buildPageNumber(3, false),
        const SizedBox(width: 10),
        Text('...',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: _subTextColor)),
        const SizedBox(width: 10),
        InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to next page...'))),
            child: Text('Next >',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: _textColor))),
      ],
    );
  }

  Widget _buildPageNumber(int page, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() => _currentPage = page);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Navigating to page $page')));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(page.toString(),
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : _textColor)),
      ),
    );
  }
}

// --- LAB CARD WIDGET ---
class _LabCard extends StatelessWidget {
  final LabInfo lab;
  final SensorData? sensorData; // Add sensor data parameter

  const _LabCard({required this.lab, this.sensorData});

  @override
  Widget build(BuildContext context) {
    // If we have sensor data, use the new Firebase card design
    if (sensorData != null) {
      return _buildFirebaseLabCard(context, sensorData!);
    }

    // Otherwise, use the old design for placeholder labs
    final isAlert = lab.status == LabStatus.overheating ||
        lab.status == LabStatus.leak_detected;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isAlert ? _alertColor : Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lab.department,
                  style: GoogleFonts.inter(
                      color: _subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 5),
          Text(lab.name,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor)),
          const SizedBox(height: 15),
          Expanded(child: _buildCardContent(context)),
          if (isAlert) ...[
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Managing alert for ${lab.name}'))),
              icon: const Icon(Icons.warning, size: 16),
              label: const Text('Manage Alert'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _alertColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 40)),
            ),
          ] else if (lab.status != LabStatus.offline) ...[
            const SizedBox(height: 15),
            InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Viewing live feed for ${lab.name}'))),
                child: Text('View Live Feed →',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700)))
          ],
        ],
      ),
    );
  }

  // New Firebase lab card design matching the sensor dashboard widget
  Widget _buildFirebaseLabCard(BuildContext context, SensorData data) {
    final alertService = AlertService();
    final isOnline = data.isOnline && !data.isStale;
    final alert = alertService.analyzeSensorData(data);

    // Determine border color and width based on alert severity
    Color borderColor;
    double borderWidth;

    if (alert.severity == AlertSeverity.critical) {
      borderColor = Colors.red;
      borderWidth = 3;
    } else if (alert.severity == AlertSeverity.warning) {
      borderColor = Colors.orange;
      borderWidth = 3;
    } else if (isOnline) {
      borderColor = Colors.green.shade200;
      borderWidth = 2;
    } else {
      borderColor = Colors.red.shade200;
      borderWidth = 2;
    }

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFirebaseLabHeader(data, isOnline),
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

  Widget _buildFirebaseLabHeader(SensorData data, bool isOnline) {
    final alertService = AlertService();
    final alert = alertService.analyzeSensorData(data);

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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      data.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  if (alert.severity == AlertSeverity.critical) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.warning, color: Colors.red, size: 20),
                  ] else if (alert.severity == AlertSeverity.warning) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  ],
                ],
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
        Container(
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
        ),
      ],
    );
  }

  Widget _buildSensorMetrics(SensorData data, bool isOnline) {
    return Column(
      children: [
        Row(
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
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricItem(
                'Humidity',
                isOnline ? '${data.humidity.toStringAsFixed(1)}%' : '--%',
                Icons.water_drop,
                Colors.blue,
                isOnline,
              ),
            ),
            const SizedBox(width: 10),
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
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Avg Temp (1h)',
                isOnline ? '${data.avgTemp.toStringAsFixed(1)}°C' : '--°C',
                Icons.trending_up,
                Colors.deepOrange,
                isOnline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricItem(
                'Avg Humidity (1h)',
                isOnline ? '${data.avgHumidity.toStringAsFixed(1)}%' : '--%',
                Icons.trending_up,
                Colors.lightBlue,
                isOnline,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
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
          child: _buildStatusChipFirebase(
            'Motion',
            data.motionDetected && isOnline,
            Icons.motion_photos_on,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatusChipFirebase(
            'AC',
            data.acStatus && isOnline,
            Icons.ac_unit,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChipFirebase(String label, bool isActive, IconData icon) {
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
    final formattedTime = data.timestamp < 1000000000
        ? 'Live'
        : 'Jan 14, 2026 ${(data.timestamp % 86400 ~/ 3600).toString().padLeft(2, '0')}:${(data.timestamp % 3600 ~/ 60).toString().padLeft(2, '0')}:${(data.timestamp % 60).toString().padLeft(2, '0')}';
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

  Widget _buildStatusChip() {
    String text = 'SAFE';
    Color color = _safeColor;
    switch (lab.status) {
      case LabStatus.overheating:
        text = 'OVERHEATING';
        color = _alertColor;
        break;
      case LabStatus.offline:
        text = 'OFFLINE';
        color = _subTextColor;
        break;
      case LabStatus.leak_detected:
        text = 'LEAK DETECTED';
        color = _alertColor;
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: GoogleFonts.inter(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    if (lab.status == LabStatus.offline) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_off_outlined,
              color: _subTextColor, size: 50),
          const SizedBox(height: 10),
          Text(lab.maintenanceNote ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: _subTextColor)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.history, size: 14, color: _subTextColor),
            const SizedBox(width: 5),
            Text('Last seen ${lab.lastSeen ?? 'N/A'}',
                style: GoogleFonts.inter(color: _subTextColor, fontSize: 12))
          ]),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(lab.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.image_not_supported)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (lab.temperature != null)
              _buildInfoItem(Icons.thermostat, 'TEMP', lab.temperature!),
            if (lab.occupancy != null)
              _buildInfoItem(Icons.person_outline, 'STATUS', lab.occupancy!),
            if (lab.load != null)
              _buildInfoItem(Icons.bolt, 'LOAD', lab.load!, isAlert: true),
            if (lab.airQuality != null)
              _buildInfoItem(Icons.air, 'AIR Q', lab.airQuality!,
                  isAlert: true),
            if (lab.lockStatus != null)
              _buildInfoItem(Icons.lock_outline, 'LOCK', lab.lockStatus!,
                  isAlert: lab.lockStatus != 'Engaged'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: isAlert ? _alertColor : _subTextColor),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _subTextColor,
                  fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 5),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAlert ? _alertColor : _textColor)),
      ],
    );
  }
}
