class TestConfig {
  final String name;
  final int packetSize;
  final int requestFrequency;
  final int testDuration;
  final String protocol;
  final TrafficPattern pattern;

  TestConfig({
    required this.name,
    required this.packetSize,
    required this.requestFrequency,
    required this.testDuration,
    required this.protocol,
    required this.pattern,
  });

  factory TestConfig.defaultConfig() {
    return TestConfig(
      name: "Default Test",
      packetSize: 1024,
      requestFrequency: 10,
      testDuration: 60,
      protocol: "HTTP",
      pattern: TrafficPattern.constant,
    );
  }
}

enum TrafficPattern {
  constant,
  burst,
  incremental,
  random,
}

extension TrafficPatternExtension on TrafficPattern {
  String get displayName {
    switch (this) {
      case TrafficPattern.constant:
        return "Constant";
      case TrafficPattern.burst:
        return "Burst";
      case TrafficPattern.incremental:
        return "Incremental";
      case TrafficPattern.random:
        return "Random";
    }
  }
}