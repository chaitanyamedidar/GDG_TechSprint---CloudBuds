
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SensorType {
  final String name;
  final String description;
  final IconData icon;

  const SensorType(this.name, this.description, this.icon);
}

const List<SensorType> sensorTypes = [
  SensorType('Temperature Sensor', 'Monitors ambient temperature.', Icons.thermostat),
  SensorType('Motion Detector', 'Detects movement in an area.', Icons.directions_run),
  SensorType('Gas Leak Monitor', 'Alerts to dangerous gas levels.', Icons.gas_meter),
  SensorType('Light Sensor', 'Measures ambient light intensity.', Icons.lightbulb),
  SensorType('Humidity Sensor', 'Tracks moisture levels.', Icons.water_drop),
];

class SelectSensorTypeScreen extends StatefulWidget {
  const SelectSensorTypeScreen({super.key});

  @override
  _SelectSensorTypeScreenState createState() => _SelectSensorTypeScreenState();
}

class _SelectSensorTypeScreenState extends State<SelectSensorTypeScreen> {
  String _selectedSensor = sensorTypes.first.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Select Sensor Type',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Choose the appropriate category for your new device.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: sensorTypes.length,
                  itemBuilder: (context, index) {
                    final sensor = sensorTypes[index];
                    final isSelected = _selectedSensor == sensor.name;
                    return _buildSensorTile(sensor, isSelected);
                  },
                ),
              ),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTile(SensorType sensor, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSensor = sensor.name;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6E6FA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(sensor.icon, color: Colors.black, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sensor.description,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(_selectedSensor);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Confirm Selection',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
