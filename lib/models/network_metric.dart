class NetworkMetric {
  final DateTime timestamp;
  final double downloadSpeed; // in bytes per second
  final double uploadSpeed; // in bytes per second
  final int latency; // in milliseconds
  final double packetLoss; // as percentage (0-100)

  NetworkMetric({
    required this.timestamp,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.latency,
    required this.packetLoss,
  });

  String get formattedDownloadSpeed => _formatDataRate(downloadSpeed);
  String get formattedUploadSpeed => _formatDataRate(uploadSpeed);

  String _formatDataRate(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return "${bytesPerSecond.toStringAsFixed(1)} B/s";
    } else if (bytesPerSecond < 1024 * 1024) {
      return "${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s";
    } else {
      return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s";
    }
  }
}