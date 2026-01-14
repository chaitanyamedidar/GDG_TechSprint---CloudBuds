import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- COLORS & STYLES ---
const Color _textColor = Color(0xFF333333);
const Color _subTextColor = Color(0xFF8A8A8E);
const Color _accentColor = Color(0xFF3F51B5);
const Color _successColor = Color(0xFF6FCF97);

class SystemAnalyticsPage extends StatelessWidget {
  const SystemAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 30),
        _buildStatsCards(context),
        const SizedBox(height: 30),
        _buildEnergyUsageTrends(context),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildConsumptionByDept(context)),
            const SizedBox(width: 30),
            Expanded(flex: 2, child: _buildAlertDistribution(context)),
          ],
        ),
        const SizedBox(height: 30),
        _buildTopSpenders(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Analytics',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor)),
            const SizedBox(height: 5),
            Text('Energy consumption & Cost analysis',
                style: GoogleFonts.inter(color: _subTextColor, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Date range filter coming soon!'))),
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: const Text('Last 30 Days'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: _textColor,
                  backgroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading PDF report...'))),
              icon: const Icon(Icons.download_for_offline_outlined, size: 18),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF2E3A59),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                title: 'Total Cost',
                value: '\$4,250',
                icon: Icons.monetization_on_outlined,
                iconBgColor: Colors.purple.shade100,
                trend: '+12%',
                trendColor: _successColor)),
        const SizedBox(width: 20),
        Expanded(
            child: _StatCard(
                title: 'Energy Consumed',
                value: '12.5 MWh',
                icon: Icons.flash_on,
                iconBgColor: Colors.blue.shade100)),
        const SizedBox(width: 20),
        Expanded(
            child: _StatCard(
                title: 'Peak Usage Time',
                value: '2:00 PM',
                icon: Icons.hourglass_top_rounded,
                iconBgColor: Colors.orange.shade100)),
        const SizedBox(width: 20),
        Expanded(
            child: _StatCard(
                title: 'Carbon Offset',
                value: '8.4 Tons',
                icon: Icons.eco_outlined,
                iconBgColor: Colors.green.shade100)),
      ],
    );
  }

  Widget _buildEnergyUsageTrends(BuildContext context) {
    return _ChartCard(
      title: 'Energy Usage Trends',
      subtitle: 'Kilowatt-hour (kWh) over 30 days',
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) => Text(
                        'Nov ${value.toInt()}',
                        style: GoogleFonts.inter(
                            color: _subTextColor, fontSize: 12)))),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 3),
                FlSpot(5, 4),
                FlSpot(10, 3.5),
                FlSpot(15, 4.5),
                FlSpot(20, 4),
                FlSpot(25, 5),
                FlSpot(30, 4.2)
              ],
              isCurved: true,
              color: _accentColor,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData:
                  BarAreaData(show: true, color: _accentColor.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionByDept(BuildContext context) {
    return _ChartCard(
      title: 'Consumption by Dept.',
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                        [
                          'Arts',
                          'Chem',
                          'Physics',
                          'Bio',
                          'Eng'
                        ][value.toInt()],
                        style: GoogleFonts.inter(
                            color: _subTextColor, fontSize: 12)))),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            _buildBarGroupData(0, 5, Colors.blue),
            _buildBarGroupData(1, 7, Colors.green),
            _buildBarGroupData(2, 4, Colors.orange),
            _buildBarGroupData(3, 8, Colors.purple),
            _buildBarGroupData(4, 6, Colors.red),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroupData(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4))
    ]);
  }

  Widget _buildAlertDistribution(BuildContext context) {
    return _ChartCard(
      title: 'Alert Distribution',
      subtitleWidget: InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Viewing alert log...'))),
          child: Text('View Log',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, color: _accentColor))),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                sections: [
                  PieChartSectionData(
                      value: 60,
                      color: Colors.blue.shade300,
                      title: '60%',
                      radius: 30,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(
                      value: 30,
                      color: Colors.yellow.shade600,
                      title: '30%',
                      radius: 30,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(
                      value: 10,
                      color: Colors.red.shade400,
                      title: '10%',
                      radius: 30,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(Colors.blue.shade300, 'AC Waste'),
              _buildLegendItem(Colors.yellow.shade600, 'Lights On'),
              _buildLegendItem(Colors.red.shade400, 'Hardware')
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text)
      ]),
    );
  }

  Widget _buildTopSpenders(BuildContext context) {
    return _ChartCard(
        title: 'Top Spenders',
        subtitleWidget: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing all labs...'))),
            child: Text('View All Labs',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: _accentColor))),
        child: Column(
          children: [
            _buildSpenderRow(context, Icons.dns, 'Server Room B', 'High',
                Colors.red.shade100, 'Dr. Sarah Jenkins', '\$1,200'),
            const Divider(height: 40),
            _buildSpenderRow(context, Icons.computer, 'Computer Lab A', 'Med',
                Colors.orange.shade100, 'Prof. Alan Turing', '\$850'),
            const Divider(height: 40),
            _buildSpenderRow(
                context,
                Icons.biotech_outlined,
                'Research Lab C',
                'Low',
                _successColor.withOpacity(0.2),
                'Dr. Rosalind Franklin',
                '\$420'),
          ],
        ));
  }

  Widget _buildSpenderRow(BuildContext context, IconData icon, String labName,
      String status, Color statusColor, String manager, String cost) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing details for $labName'))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 3,
              child: Row(children: [
                Icon(icon, color: _subTextColor),
                const SizedBox(width: 15),
                Text(labName,
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ])),
          Expanded(
              flex: 2,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)))),
          Expanded(flex: 3, child: Text(manager, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(cost,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

// --- COMMON WIDGETS ---
class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconBgColor;
  final String? trend;
  final Color? trendColor;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.iconBgColor,
      this.trend,
      this.trendColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: iconBgColor,
                  child: Icon(icon, color: const Color(0xFF2E3A59), size: 20)),
              if (trend != null)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color:
                            trendColor?.withOpacity(0.1) ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(trend!,
                        style: TextStyle(
                            color: trendColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              style: GoogleFonts.inter(color: _subTextColor, fontSize: 14)),
          const SizedBox(height: 5),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _textColor)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget child;

  const _ChartCard(
      {required this.title,
      this.subtitle,
      this.subtitleWidget,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.inter(color: _subTextColor))
              ]),
              if (subtitleWidget != null) subtitleWidget!,
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 250, child: child),
        ],
      ),
    );
  }
}
