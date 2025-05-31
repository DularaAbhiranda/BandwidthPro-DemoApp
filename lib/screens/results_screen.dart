import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/network_metric.dart';
import '../models/test_config.dart';

class ResultsScreen extends StatelessWidget {
  final List<NetworkMetric> metrics;
  final TestConfig config;

  const ResultsScreen({
    Key? key,
    required this.metrics,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share results
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () {
              // TODO: Export results
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildChartsSection(),
            const SizedBox(height: 16),
            _buildStatsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Calculate summary statistics
    final avgDownload = metrics.isEmpty
        ? 0.0
        : metrics.map((m) => m.downloadSpeed).reduce((a, b) => a + b) / metrics.length;

    final avgUpload = metrics.isEmpty
        ? 0.0
        : metrics.map((m) => m.uploadSpeed).reduce((a, b) => a + b) / metrics.length;

    final avgLatency = metrics.isEmpty
        ? 0
        : metrics.map((m) => m.latency).reduce((a, b) => a + b) ~/ metrics.length;

    final maxDownload = metrics.isEmpty
        ? 0.0
        : metrics.map((m) => m.downloadSpeed).reduce((a, b) => a > b ? a : b);

    final minLatency = metrics.isEmpty
        ? 0
        : metrics.map((m) => m.latency).reduce((a, b) => a < b ? a : b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Test Summary: ${config.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Average Download',
              NetworkMetric(
                timestamp: DateTime.now(),
                downloadSpeed: avgDownload,
                uploadSpeed: 0,
                latency: 0,
                packetLoss: 0,
              ).formattedDownloadSpeed,
            ),
            _buildSummaryItem(
              'Average Upload',
              NetworkMetric(
                timestamp: DateTime.now(),
                downloadSpeed: 0,
                uploadSpeed: avgUpload,
                latency: 0,
                packetLoss: 0,
              ).formattedUploadSpeed,
            ),
            _buildSummaryItem('Average Latency', '$avgLatency ms'),
            _buildSummaryItem(
              'Max Download',
              NetworkMetric(
                timestamp: DateTime.now(),
                downloadSpeed: maxDownload,
                uploadSpeed: 0,
                latency: 0,
                packetLoss: 0,
              ).formattedDownloadSpeed,
            ),
            _buildSummaryItem('Min Latency', '$minLatency ms'),
            _buildSummaryItem('Test Duration', '${config.testDuration} seconds'),
            _buildSummaryItem('Traffic Pattern', config.pattern.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Graphs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bandwidth Usage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBandwidthChart(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latency',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildLatencyChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBandwidthChart() {
    if (metrics.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0) {
                  final index = value.toInt();
                  if (index >= 0 && index < metrics.length) {
                    return Text('${index}s');
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} MB/s');
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (metrics.length - 1).toDouble(),
        minY: 0,
        maxY: (metrics.map((e) => e.downloadSpeed / (1024 * 1024)).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          // Download speed
          LineChartBarData(
            spots: List.generate(metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                metrics[index].downloadSpeed / (1024 * 1024), // Convert to MB/s
              );
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          // Upload speed
          LineChartBarData(
            spots: List.generate(metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                metrics[index].uploadSpeed / (1024 * 1024), // Convert to MB/s
              );
            }),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyChart() {
    if (metrics.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0) {
                  final index = value.toInt();
                  if (index >= 0 && index < metrics.length) {
                    return Text('${index}s');
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()} ms');
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (metrics.length - 1).toDouble(),
        minY: 0,
        maxY: (metrics.map((e) => e.latency.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          // Latency
          LineChartBarData(
            spots: List.generate(metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                metrics[index].latency.toDouble(),
              );
            }),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Download')),
                  DataColumn(label: Text('Upload')),
                  DataColumn(label: Text('Latency')),
                  DataColumn(label: Text('Packet Loss')),
                ],
                rows: metrics.map((metric) {
                  final time = '${metric.timestamp.minute}:${metric.timestamp.second.toString().padLeft(2, '0')}';
                  return DataRow(
                    cells: [
                      DataCell(Text(time)),
                      DataCell(Text(metric.formattedDownloadSpeed)),
                      DataCell(Text(metric.formattedUploadSpeed)),
                      DataCell(Text('${metric.latency} ms')),
                      DataCell(Text('${metric.packetLoss.toStringAsFixed(1)}%')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}