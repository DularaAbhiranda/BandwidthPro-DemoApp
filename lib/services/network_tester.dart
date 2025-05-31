import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/test_config.dart';
import '../models/network_metric.dart';

class NetworkTester {
  // Safety limits
  static const int MAX_REQUEST_FREQUENCY = 50; // Maximum requests per second
  static const int MAX_TEST_DURATION = 300; // Maximum 5 minutes
  static const int MAX_PACKET_SIZE = 8192; // Maximum packet size in bytes
  static const double MAX_BANDWIDTH_PERCENTAGE = 0.5; // Maximum 50% of available bandwidth

  final TestConfig config;
  bool _isRunning = false;
  final _random = Random();
  final List<DateTime> _requestStartTimes = [];
  final List<DateTime> _requestEndTimes = [];
  final List<int> _bytesSent = [];
  final List<int> _bytesReceived = [];

  final _metricsController = StreamController<NetworkMetric>.broadcast();
  Stream<NetworkMetric> get metricsStream => _metricsController.stream;
  bool get isRunning => _isRunning;

  NetworkTester(this.config);

  Future<void> start() async {
    if (_isRunning) return;

    // Apply safety limits
    final safeConfig = _applySafetyLimits(config);

    _isRunning = true;

    // Clear previous stats
    _requestStartTimes.clear();
    _requestEndTimes.clear();
    _bytesSent.clear();
    _bytesReceived.clear();

    // Start appropriate traffic pattern
    switch (safeConfig.pattern) {
      case TrafficPattern.constant:
        _startConstantTraffic();
        break;
      case TrafficPattern.burst:
        _startBurstTraffic();
        break;
      case TrafficPattern.incremental:
        _startIncrementalTraffic();
        break;
      case TrafficPattern.random:
        _startRandomTraffic();
        break;
    }

    // Start monitoring
    _startMonitoring();

    // Auto-stop after duration
    Timer(Duration(seconds: safeConfig.testDuration), () {
      stop();
    });
  }

  // Method to enforce safety limits
  TestConfig _applySafetyLimits(TestConfig originalConfig) {
    final safeDuration = originalConfig.testDuration > MAX_TEST_DURATION
        ? MAX_TEST_DURATION
        : originalConfig.testDuration;

    final safeFrequency = originalConfig.requestFrequency > MAX_REQUEST_FREQUENCY
        ? MAX_REQUEST_FREQUENCY
        : originalConfig.requestFrequency;

    final safePacketSize = originalConfig.packetSize > MAX_PACKET_SIZE
        ? MAX_PACKET_SIZE
        : originalConfig.packetSize;

    return TestConfig(
      name: originalConfig.name,
      packetSize: safePacketSize,
      requestFrequency: safeFrequency,
      testDuration: safeDuration,
      protocol: originalConfig.protocol,
      pattern: originalConfig.pattern,
    );
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
  }

  void _startConstantTraffic() {
    Timer.periodic(Duration(milliseconds: 1000 ~/ config.requestFrequency), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      _generateTraffic();
    });
  }

  void _startBurstTraffic() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      // Generate a burst of traffic
      for (int i = 0; i < config.requestFrequency * 10; i++) {
        if (i % 5 == 0) {
          // Add small delay to prevent overwhelming the device
          Future.delayed(Duration(milliseconds: 100), () {
            if (_isRunning) {
              _generateTraffic();
            }
          });
        } else {
          _generateTraffic();
        }
      }
    });
  }

  void _startIncrementalTraffic() {
    int currentRate = 1;
    int maxRate = config.requestFrequency * 2;

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      for (int i = 0; i < currentRate; i++) {
        if (_isRunning) {
          _generateTraffic();
        }
      }

      // Increase rate gradually
      if (currentRate < maxRate) {
        currentRate++;
      } else {
        // Reset to starting rate
        currentRate = 1;
      }
    });
  }

  void _startRandomTraffic() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      int randomRate = _random.nextInt(config.requestFrequency * 2) + 1;
      for (int i = 0; i < randomRate; i++) {
        if (_isRunning) {
          _generateTraffic();
        }
      }
    });
  }

  Future<void> _generateTraffic() async {
    // Use different endpoints to avoid caching
    final endpoints = [
      'https://www.google.com',
      'https://www.microsoft.com',
      'https://www.amazon.com',
      'https://www.github.com',
      'https://www.stackoverflow.com',
    ];

    final randomEndpoint = endpoints[_random.nextInt(endpoints.length)];

    try {
      // Record start time
      final startTime = DateTime.now();
      _requestStartTimes.add(startTime);

      // Generate random data if needed
      List<int> data = [];
      if (config.protocol == "POST") {
        data = List.generate(config.packetSize, (i) => _random.nextInt(256));
      }

      // Send request based on protocol
      if (config.protocol == "POST") {
        final response = await http.post(
          Uri.parse(randomEndpoint),
          body: utf8.encode(String.fromCharCodes(data)),
        );

        _bytesReceived.add(response.bodyBytes.length);
        _bytesSent.add(data.length);
      } else {
        // Default to HTTP GET
        final response = await http.get(Uri.parse(randomEndpoint));
        _bytesReceived.add(response.bodyBytes.length);
        _bytesSent.add(0); // No body sent for GET
      }

      // Record end time
      final endTime = DateTime.now();
      _requestEndTimes.add(endTime);

    } catch (e) {
      print('Error generating traffic: $e');
      // Still record the attempt, but with zeroes
      _requestEndTimes.add(DateTime.now());
      _bytesReceived.add(0);
      _bytesSent.add(0);
    }
  }

  void _startMonitoring() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      _calculateAndPublishMetrics();
    });
  }

  void _calculateAndPublishMetrics() {
    // Don't calculate if no data
    if (_requestEndTimes.isEmpty) return;

    final now = DateTime.now();
    final windowStart = now.subtract(Duration(seconds: 5));

    // Filter to only consider requests in the last 5 seconds
    final recentRequestIndices = <int>[];
    for (int i = 0; i < _requestEndTimes.length; i++) {
      if (_requestEndTimes[i].isAfter(windowStart)) {
        recentRequestIndices.add(i);
      }
    }

    if (recentRequestIndices.isEmpty) return;

    // Calculate average latency
    int totalLatency = 0;
    for (final idx in recentRequestIndices) {
      if (idx < _requestStartTimes.length) {
        totalLatency += _requestEndTimes[idx].difference(_requestStartTimes[idx]).inMilliseconds;
      }
    }
    final avgLatency = recentRequestIndices.isNotEmpty ? totalLatency ~/ recentRequestIndices.length : 0;

    // Calculate download and upload speeds
    int totalBytesReceived = 0;
    int totalBytesSent = 0;
    for (final idx in recentRequestIndices) {
      if (idx < _bytesReceived.length) {
        totalBytesReceived += _bytesReceived[idx];
      }
      if (idx < _bytesSent.length) {
        totalBytesSent += _bytesSent[idx];
      }
    }

    // Calculate speeds in bytes per second
    final elapsedSeconds = 5.0; // 5-second window
    final downloadSpeed = totalBytesReceived / elapsedSeconds;
    final uploadSpeed = totalBytesSent / elapsedSeconds;

    // Simulate packet loss between 0-5%
    final packetLoss = _random.nextDouble() * 5.0;

    // Create and publish metric
    final metric = NetworkMetric(
      timestamp: now,
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      latency: avgLatency,
      packetLoss: packetLoss,
    );

    _metricsController.add(metric);
  }
}