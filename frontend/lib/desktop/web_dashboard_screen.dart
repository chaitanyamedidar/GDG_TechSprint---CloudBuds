import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_labs/desktop/all_laboratories_page.dart';
import 'package:safe_labs/desktop/dean_login_screen.dart';
import 'package:safe_labs/desktop/settings_page.dart';
import 'package:safe_labs/desktop/system_analytics_page.dart';
import 'package:safe_labs/core/widgets/sensor_dashboard_widget.dart';
import 'package:safe_labs/core/widgets/alert_notification_widget.dart';

const Color _backgroundColor = Color(0xFFF7F8FC);
const Color _navBarColor = Colors.white;
const Color _activeNavItemColor = Color(0xFFE8EAFC);
const Color _activeNavIconTextColor = Color(0xFF3F51B5);
const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  String _selectedNavItem = 'Overview';
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final results = await FirebaseFunctions.instance
          .httpsCallable('getDashboardData')
          .call();
      if (mounted) {
        setState(() {
          _userData = Map<String, dynamic>.from(results.data['user']);
          _isLoading = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message ?? 'Failed to load user data.'),
              backgroundColor: Colors.red),
        );
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DeanLoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                _buildSideBar(),
                _buildMainContent(),
              ],
            ),
    );
  }

  Widget _buildSideBar() {
    return Container(
      width: 260,
      color: _navBarColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.biotech_rounded, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              Text('SafeLabs',
                  style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textColor)),
            ],
          ),
          const SizedBox(height: 50),
          _buildNavItem(
              Icons.home_work_rounded,
              'Overview',
              _selectedNavItem == 'Overview',
              () => setState(() => _selectedNavItem = 'Overview')),
          _buildNavItem(
              Icons.grid_view_rounded,
              'All Labs',
              _selectedNavItem == 'All Labs',
              () => setState(() => _selectedNavItem = 'All Labs')),
          _buildNavItem(
              Icons.analytics_outlined,
              'Analytics',
              _selectedNavItem == 'Analytics',
              () => setState(() => _selectedNavItem = 'Analytics')),
          _buildNavItem(
              Icons.settings_outlined,
              'Settings',
              _selectedNavItem == 'Settings',
              () => setState(() => _selectedNavItem = 'Settings')),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => _selectedNavItem = 'Settings'),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    _userData?['avatar_url'] as String? ??
                        'https://placehold.co/100x100/E8EAFC/3F51B5?text=${_userData?['full_name']?[0] ?? 'D'}',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userData?['full_name'] as String? ?? 'Campus Dean',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, color: _textColor)),
                    Text(_userData?['role'] as String? ?? 'Administrator',
                        style: GoogleFonts.inter(
                            color: _subTextColor, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _activeNavItemColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? _activeNavIconTextColor : _subTextColor,
                size: 22),
            const SizedBox(width: 16),
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? _activeNavIconTextColor : _textColor,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: _getSelectedContent(),
      ),
    );
  }

  Widget _getSelectedContent() {
    switch (_selectedNavItem) {
      case 'All Labs':
        return const AllLaboratoriesPage();
      case 'Analytics':
        return const SystemAnalyticsPage();
      case 'Settings':
        return const SettingsPage();
      case 'Overview':
      default:
        return const _OverviewContent();
    }
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainHeader(context),
        const SizedBox(height: 30),
        _buildStatsCards(context),
        const SizedBox(height: 30),
        // Real-time Sensor Data from Wokwi Simulators
        const SensorDashboardWidget(),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveViewMap(),
            const SizedBox(width: 30),
            _buildUrgentAttention(context),
          ],
        ),
        const SizedBox(height: 30),
        const _EnergyTrends(),
      ],
    );
  }

  Widget _buildMainHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus Overview',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor)),
            const SizedBox(height: 5),
            Text('Real-time infrastructure monitoring',
                style: GoogleFonts.inter(color: _subTextColor, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            const AlertNotificationWidget(),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading report...'))),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download Report'),
              style: ElevatedButton.styleFrom(
                foregroundColor: _textColor,
                backgroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(context, 'Total Active Labs', '42',
                Icons.business_sharp, Colors.grey.shade300,
                hasInfo: true)),
        const SizedBox(width: 20),
        Expanded(
            child: _buildStatCard(context, 'Critical Alerts', '3',
                Icons.warning_amber_rounded, Colors.red.shade100,
                isAlert: true)),
        const SizedBox(width: 20),
        Expanded(
            child: _buildStatCard(context, 'Energy Saved Today', '128 kWh',
                Icons.eco_outlined, Colors.green.shade100)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color iconBgColor,
      {bool isAlert = false, bool hasInfo = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Row(
        children: [
          CircleAvatar(
              radius: 24,
              backgroundColor: iconBgColor,
              child: Icon(icon,
                  color:
                      isAlert ? Colors.red.shade700 : const Color(0xFF2E3A59))),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(color: _subTextColor, fontSize: 14)),
              const SizedBox(height: 5),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isAlert ? Colors.red.shade700 : _textColor)),
            ],
          ),
          if (hasInfo) ...[
            const Spacer(),
            IconButton(
              icon: Icon(Icons.info_outline,
                  color: _subTextColor.withOpacity(0.7), size: 20),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          '42 labs are currently online and reporting data.'))),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildLiveViewMap() {
    return Expanded(
      flex: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 400,
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(19.0473, 72.9052),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentAttention(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Urgent Attention',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textColor)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('2 Active',
                      style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)))
            ]),
            const SizedBox(height: 20),
            _buildAttentionItem(context, Icons.error, 'Gas Leak',
                'Lab 04 - Chemical Wing', '2m ago', true),
            const Divider(height: 30),
            _buildAttentionItem(context, Icons.ac_unit, 'AC Malfunction',
                'Server Room - Block B', '15m ago', false),
            const Divider(height: 30),
            _buildAttentionItem(
                context,
                Icons.door_sliding_outlined,
                'Door Propped Open',
                'Main Entrance - Lab 01',
                '45m ago',
                false),
            const Spacer(),
            Center(
              child: InkWell(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing all alerts...'))),
                child: Text('View All Alerts',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: _activeNavIconTextColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttentionItem(BuildContext context, IconData icon, String title,
      String subtitle, String time, bool isUrgent) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Viewing details for: $title'))),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor:
                  isUrgent ? Colors.red.withOpacity(0.1) : Colors.grey.shade200,
              child: Icon(icon,
                  color: isUrgent ? Colors.red.shade700 : _textColor,
                  size: 20)),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle,
                    style:
                        GoogleFonts.inter(color: _subTextColor, fontSize: 12))
              ])),
          Text(time,
              style: GoogleFonts.inter(
                  color: isUrgent ? Colors.red : _subTextColor,
                  fontSize: 12,
                  fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _EnergyTrends extends StatefulWidget {
  const _EnergyTrends();

  @override
  State<_EnergyTrends> createState() => _EnergyTrendsState();
}

class _EnergyTrendsState extends State<_EnergyTrends> {
  String _selectedTrend = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Energy Consumption Trends',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Daily usage across all active campuses',
                  style: GoogleFonts.inter(color: _subTextColor))
            ]),
            Row(children: [
              _buildTrendButton('Daily', _selectedTrend == 'Daily'),
              _buildTrendButton('Weekly', _selectedTrend == 'Weekly'),
              _buildTrendButton('Monthly', _selectedTrend == 'Monthly'),
            ])
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartSpots(),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: Colors.purple.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    // In a real app, you would fetch data based on the selected trend
    switch (_selectedTrend) {
      case 'Monthly':
        return [
          const FlSpot(0, 4),
          const FlSpot(2, 3),
          const FlSpot(4, 5),
          const FlSpot(6, 4.5),
          const FlSpot(8, 6),
          const FlSpot(10, 5),
          const FlSpot(11, 7)
        ];
      case 'Weekly':
        return [
          const FlSpot(0, 1),
          const FlSpot(1.5, 3),
          const FlSpot(3, 2),
          const FlSpot(4.5, 4),
          const FlSpot(6, 3),
          const FlSpot(7.5, 5),
          const FlSpot(11, 4)
        ];
      case 'Daily':
      default:
        return [
          const FlSpot(0, 3),
          const FlSpot(2.6, 2),
          const FlSpot(4.9, 5),
          const FlSpot(6.8, 3.1),
          const FlSpot(8, 4),
          const FlSpot(9.5, 3),
          const FlSpot(11, 4)
        ];
    }
  }

  Widget _buildTrendButton(String text, bool isActive) {
    return InkWell(
      onTap: () => setState(() => _selectedTrend = text),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color:
                isActive ? Colors.green.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: GoogleFonts.inter(
                color: isActive ? Colors.green.shade800 : _subTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final String title;
  const _PlaceholderContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
      ),
    );
  }
}
