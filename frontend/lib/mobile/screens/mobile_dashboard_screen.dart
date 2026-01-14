
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/core/styles.dart';
import 'package:safe_labs/mobile/screens/mobile_add_sensor_screen.dart';
import 'package:safe_labs/mobile/screens/mobile_select_sensor_type_screen.dart';

// --- DATA MODELS ---
class LabData {
  final String labName;
  final String labStatus;
  final int temperature;
  bool isACMasterOn;

  LabData({
    required this.labName,
    required this.labStatus,
    required this.temperature,
    required this.isACMasterOn,
  });
}

class SensorCardData {
  final String id;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  SensorCardData({
    required this.id,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// --- UI CONSTANTS ---
const Color offWhite = Color(0xFFF5F5F7);
const Color lavender = Color(0xFFE6E6FA);
const Color lightBlue = Color(0xFFADD8E6);
const Color cyanMint = Color(0xFFE0F7FA);
const Color softPink = Color(0xFFFADADD);
const Color softGreen = Color(0xFFD4F1F4);
const Color blackText = Color(0xFF1A1A1A);
const Color greyText = Color(0xFF8A8A8E);

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  LabData? _labData;
  List<SensorCardData> _sensors = [];
  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    _fetchLabData();
  }

  void _fetchLabData() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _labData = LabData(
          labName: "Lab 01",
          labStatus: "Status: Online & Secure",
          temperature: 24,
          isACMasterOn: true,
        );
        _sensors = [
          SensorCardData(id: 'gas', title: "Gas Level", value: "Normal (12ppm)", icon: Icons.gas_meter_outlined, color: lightBlue),
          SensorCardData(id: 'light', title: "Ambient Light", value: "85% (On)", icon: Icons.lightbulb_outline, color: cyanMint),
          SensorCardData(id: 'motion', title: "Motion", value: "None", icon: Icons.directions_run, color: softPink),
          SensorCardData(id: 'door', title: "Door Lock", value: "Engaged", icon: Icons.lock_outline, color: softGreen),
        ];
      });
    });
  }

  void _updateACState(bool newState) {
    if (!mounted) return;
    setState(() {
      _labData?.isACMasterOn = newState;
    });
  }

  void _addSensor(String deviceName, String sensorType) {
    final newSensor = SensorCardData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: deviceName,
      value: "Reading...",
      icon: _getIconForSensorType(sensorType),
      color: _getColorForSensorType(sensorType),
    );
    setState(() {
      _sensors.add(newSensor);
    });
  }

  void _deleteSensor(String id) {
    setState(() {
      _sensors.removeWhere((sensor) => sensor.id == id);
    });
  }

  IconData _getIconForSensorType(String sensorType) {
    final type = sensorTypes.firstWhere((t) => t.name == sensorType, orElse: () => sensorTypes.first);
    return type.icon;
  }

  Color _getColorForSensorType(String sensorType) {
    final availableColors = [lightBlue, cyanMint, softPink, softGreen, Colors.orange.shade100, Colors.teal.shade100];
    return availableColors[Random().nextInt(availableColors.length)];
  }

  void _showAddSensorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => AddNewSensorScreen(onSensorAdded: _addSensor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_labData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 120),
      children: [
        _buildHeader(_labData!.labName, _labData!.labStatus),
        const SizedBox(height: 30),
        _buildHeroSection(_labData!.temperature, _labData!.isACMasterOn),
        const SizedBox(height: 20),
        _buildSensorGrid(),
        const SizedBox(height: 30),
        _buildDeleteModeToggle(),
      ],
    );
  }

  Widget _buildHeader(String name, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: blackText), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(status, style: GoogleFonts.inter(fontSize: 16, color: greyText, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [AppleShadows.button],
          ),
          child: ElevatedButton.icon(
            onPressed: _showAddSensorSheet,
            icon: const Icon(Icons.add, size: 16),
            label: const Text("Add Sensor"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: blackText,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(int temp, bool isAcOn) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.0), boxShadow: const [AppleShadows.card]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            color: lavender.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(temp.toString(), style: GoogleFonts.inter(fontSize: 60, fontWeight: FontWeight.bold, color: blackText, height: 1)),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("°C", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: blackText)),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("AC MASTER POWER", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: blackText.withOpacity(0.7))),
                    const SizedBox(height: 4),
                    Text(isAcOn ? "On" : "Off", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: blackText)),
                    const SizedBox(height: 8),
                    Switch(value: isAcOn, onChanged: _updateACState, activeColor: Colors.greenAccent.shade400, activeTrackColor: Colors.green.shade100),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: _sensors.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final sensor = _sensors[index];
        return _buildSensorCard(sensor: sensor);
      },
    );
  }

  Widget _buildSensorCard({required SensorCardData sensor}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.0), boxShadow: const [AppleShadows.card]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            color: sensor.color.withOpacity(0.85),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(sensor.icon, size: 32, color: blackText),
                    const Spacer(),
                    Text(sensor.title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: blackText)),
                    const SizedBox(height: 4),
                    Text(sensor.value, style: GoogleFonts.inter(fontSize: 14, color: greyText, fontWeight: FontWeight.w500)),
                  ],
                ),
                if (_deleteMode)
                  Positioned(
                    top: -10,
                    right: -10,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                      onPressed: () => _deleteSensor(sensor.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _deleteMode,
          onChanged: (val) => setState(() => _deleteMode = val ?? false),
          activeColor: Colors.redAccent,
        ),
        Text(
          "Delete Sensors",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: _deleteMode ? Colors.redAccent : blackText),
        ),
      ],
    );
  }
}
