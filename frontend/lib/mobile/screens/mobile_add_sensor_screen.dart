
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_labs/mobile/screens/mobile_select_sensor_type_screen.dart';

class AddNewSensorScreen extends StatefulWidget {
  final Function(String deviceName, String sensorType) onSensorAdded;

  const AddNewSensorScreen({super.key, required this.onSensorAdded});

  @override
  _AddNewSensorScreenState createState() => _AddNewSensorScreenState();
}

class _AddNewSensorScreenState extends State<AddNewSensorScreen> {
  String _deviceName = '';
  final String _deviceId = 'ESP32-8821-X'; // Prefilled from image
  String _sensorType = 'Standard Environment Kit';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Sensor',
                  style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Scan the QR code on your SafeLabs device.',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Align QR code here',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Device Name', 'e.g., Physics Lab East', (value) => _deviceName = value),
            const SizedBox(height: 16),
            _buildTextField('Device ID', _deviceId, (value) {}, readOnly: true),
            const SizedBox(height: 16),
            _buildSensorTypeSelector(context),
            const SizedBox(height: 30),
            _buildAddSensorButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, ValueChanged<String> onChanged, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: readOnly,
          initialValue: readOnly ? placeholder : null,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: readOnly ? null : placeholder,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Type',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedSensor = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SelectSensorTypeScreen(),
                fullscreenDialog: true,
              ),
            );
            if (selectedSensor != null) {
              setState(() {
                _sensorType = selectedSensor;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sensorType,
                  style: GoogleFonts.inter(),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddSensorButton() {
    return ElevatedButton(
      onPressed: () {
        if (_deviceName.isNotEmpty) {
          widget.onSensorAdded(_deviceName, _sensorType);
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a device name.')),
          );
        }
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
        'Add Sensor',
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
