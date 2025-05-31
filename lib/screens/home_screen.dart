import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../services/network_tester.dart';
import '../models/network_metric.dart';
import 'package:fl_chart/fl_chart.dart';
import 'settings_screen.dart';
import 'results_screen.dart';
import 'education_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TestConfig _config = TestConfig.defaultConfig();
  late NetworkTester _networkTester;
  bool _isRunning = false;
  final List<NetworkMetric> _metrics = [];
  final int _maxDataPoints = 60; // Show max 1 minute of data

  @override
  void initState() {
    super.initState();
    _networkTester = NetworkTester(_config);
    _networkTester.metricsStream.listen((metric) {
      setState(() {
        _metrics.add(metric);
        if (_metrics.length > _maxDataPoints) {
          _metrics.removeAt(0);
        }
      });
    });
  }

  void _startTest() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _metrics.clear();
    });
    await _networkTester.start();
  }

  void _stopTest() {
    if (!_isRunning) return;
    _networkTester.stop();
    setState(() {
      _isRunning = false;
    });

    // Navigate to results screen when test is complete
    if (_metrics.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            metrics: List.from(_metrics),
            config: _config,
          ),
        ),
      );
    }
  }

  void _updateConfig(TestConfig newConfig) {
    setState(() {
      _config = newConfig;
      _networkTester = NetworkTester(_config);
      _networkTester.metricsStream.listen((metric) {
        setState(() {
          _metrics.add(metric);
          if (_metrics.length > _maxDataPoints) {
            _metrics.removeAt(0);
          }
        });
      });
    });
  }

  void _showSafetyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Network Test Warning'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to run a network load test which may temporarily affect network performance for all users on this network.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Please confirm:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• You own this network or have permission to test it'),
            Text('• Other users have been notified if appropriate'),
            Text('• This is an appropriate time to conduct testing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'PROCEED',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandwidthPro'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _isRunning ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    config: _config,
                    onConfigUpdated: _updateConfig,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EducationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Status Card
            _buildNetworkStatusCard(),
            const SizedBox(height: 16),

            // Quick Settings Card
            _buildQuickSettingsCard(),
            const SizedBox(height: 16),

            // Start/Stop Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isRunning ? _stopTest : _showSafetyDialog,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Stop Test' : 'Start Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Performance Charts
            if (_metrics.isNotEmpty) _buildPerformanceCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    final latestMetric = _metrics.isNotEmpty ? _metrics.last : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    // Refresh network status
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatusItem(
                  'Download',
                  latestMetric?.formattedDownloadSpeed ?? 'N/A',
                ),
                _buildStatusItem(
                  'Upload',
                  latestMetric?.formattedUploadSpeed ?? 'N/A',
                ),
                _buildStatusItem(
                  'Latency',
                  latestMetric != null ? '${latestMetric.latency} ms' : 'N/A',
                ),
                _buildStatusItem(
                  'Packet Loss',
                  latestMetric != null ? '${latestMetric.packetLoss.toStringAsFixed(1)}%' : 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, size: 20),
                  onPressed: _isRunning ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          config: _config,
                          onConfigUpdated: _updateConfig,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TrafficPattern>(
              decoration: const InputDecoration(
                labelText: 'Traffic Pattern',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              value: _config.pattern,
              items: TrafficPattern.values.map((pattern) {
                return DropdownMenuItem(
                  value: pattern,
                  child: Text(pattern.displayName),
                );
              }).toList(),
              onChanged: _isRunning ? null : (value) {
                if (value != null) {
                  setState(() {
                    _config = TestConfig(
                      name: _config.name,
                      packetSize: _config.packetSize,
                      requestFrequency: _config.requestFrequency,
                      testDuration: _config.testDuration,
                      protocol: _config.protocol,
                      pattern: value,
                    );
                    _networkTester = NetworkTester(_config);
                    _networkTester.metricsStream.listen((metric) {
                      setState(() {
                        _metrics.add(metric);
                        if (_metrics.length > _maxDataPoints) {
                          _metrics.removeAt(0);
                        }
                      });
                    });
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Duration (seconds)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    initialValue: _config.testDuration.toString(),
                    keyboardType: TextInputType.number,
                    enabled: !_isRunning,
                    onChanged: (value) {
                      final duration = int.tryParse(value);
                      if (duration != null && duration > 0) {
                        setState(() {
                          _config = TestConfig(
                            name: _config.name,
                            packetSize: _config.packetSize,
                            requestFrequency: _config.requestFrequency,
                            testDuration: duration,
                            protocol: _config.protocol,
                            pattern: _config.pattern,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Request Frequency',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    initialValue: _config.requestFrequency.toString(),
                    keyboardType: TextInputType.number,
                    enabled: !_isRunning,
                    onChanged: (value) {
                      final frequency = int.tryParse(value);
                      if (frequency != null && frequency > 0) {
                        setState(() {
                          _config = TestConfig(
                            name: _config.name,
                            packetSize: _config.packetSize,
                            requestFrequency: frequency,
                            testDuration: _config.testDuration,
                            protocol: _config.protocol,
                            pattern: _config.pattern,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
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
          child: _buildBandwidthChart(),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
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
          child: _buildLatencyChart(),
        ),
      ],
    );
  }

  Widget _buildBandwidthChart() {
    if (_metrics.isEmpty) {
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
                  if (index >= 0 && index < _metrics.length) {
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
        maxX: (_metrics.length - 1).toDouble(),
        minY: 0,
        maxY: (_metrics.map((e) => e.downloadSpeed / (1024 * 1024)).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          // Download speed
          LineChartBarData(
            spots: List.generate(_metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                _metrics[index].downloadSpeed / (1024 * 1024), // Convert to MB/s
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
            spots: List.generate(_metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                _metrics[index].uploadSpeed / (1024 * 1024), // Convert to MB/s
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
    if (_metrics.isEmpty) {
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
                  if (index >= 0 && index < _metrics.length) {
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
        maxX: (_metrics.length - 1).toDouble(),
        minY: 0,
        maxY: (_metrics.map((e) => e.latency.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          // Latency
          LineChartBarData(
            spots: List.generate(_metrics.length, (index) {
              return FlSpot(
                index.toDouble(),
                _metrics[index].latency.toDouble(),
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
}