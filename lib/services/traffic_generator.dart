import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/test_config.dart';
import '../models/network_metric.dart';

class TrafficGenerator {
  final TestConfig config;
  bool _isRunning = false;
  final _random = Random();
  final List<Socket> _activeSockets = [];
  final List<HttpClient> _activeClients = [];
  final _metricsController = StreamController<NetworkMetric>.broadcast();

  Stream<NetworkMetric> get metricsStream => _metricsController.stream;
  bool get isRunning => _isRunning;

  TrafficGenerator(this.config);

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    switch (config.pattern) {
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
    Timer(Duration(seconds: config.testDuration), () {
      stop();
    });
  }

  void stop() {
    if (!_isRunning) return;
    _isRunning = false;

    // Clean up resources
    for (var socket in _activeSockets) {
      socket.destroy();
    }
    _activeSockets.clear();

    for (var client in _activeClients) {
      client.close();
    }
    _activeClients.clear();
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

      // Burst of 10x normal rate for 1 second
      for (int i = 0; i < config.requestFrequency * 10; i++) {
        _generateTraffic();
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
        _generateTraffic();
      }

      // Increase rate each second
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
        _generateTraffic();
      }
    });
  }

  Future<void> _generateTraffic() async {
    if (config.protocol == "TCP") {
      _generateTcpTraffic();
    } else if (config.protocol == "UDP") {
      _generateUdpTraffic();
    } else {
      // Default to HTTP
      _generateHttpTraffic();
    }
  }

  Future<void> _generateTcpTraffic() async {
    try {
      final socket = await Socket.connect('8.8.8.8', 53);
      _activeSockets.add(socket);

      List<int> data = List.generate(config.packetSize, (i) => _random.nextInt(256));
      socket.add(data);

      // Cleanup after 5 seconds
      Timer(Duration(seconds: 5), () {
        socket.destroy();
        _activeSockets.remove(socket);
      });
    } catch (e) {
      print('Error generating TCP traffic: $e');
    }
  }

  Future<void> _generateUdpTraffic() async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      List<int> data = List.generate(config.packetSize, (i) => _random.nextInt(256));

      socket.send(data, InternetAddress('8.8.8.8'), 53);

      // Cleanup after 1 second
      Timer(Duration(seconds: 1), () {
        socket.close();
      });
    } catch (e) {
      print('Error generating UDP traffic: $e');
    }
  }

  Future<void> _generateHttpTraffic() async {
    try {
      final client = HttpClient();
      _activeClients.add(client);

      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      final response = await request.close();

      // Read and discard response
      await response.drain();

      // Cleanup
      Timer(Duration(seconds: 2), () {
        client.close();
        _activeClients.remove(client);
      });
    } catch (e) {
      print('Error generating HTTP traffic: $e');
    }
  }

  void _startMonitoring() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      _measureNetworkMetrics();
    });
  }

  Future<void> _measureNetworkMetrics() async {
    try {
      // In a real app, you would use platform-specific code to get accurate metrics
      // This is a simplified simulation
      final timestamp = DateTime.now();

      // Simulate metrics based on active connections
      final downloadSpeed = _random.nextDouble() * 1024 * 1024 * (_activeSockets.length + _activeClients.length + 1);
      final uploadSpeed = _random.nextDouble() * 512 * 1024 * (_activeSockets.length + _activeClients.length + 1);
      final latency = 20 + _random.nextInt(80);
      final packetLoss = _random.nextDouble() * 5;

      final metric = NetworkMetric(
        timestamp: timestamp,
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        latency: latency,
        packetLoss: packetLoss,
      );

      _metricsController.add(metric);
    } catch (e) {
      print('Error measuring network metrics: $e');
    }
  }
}


