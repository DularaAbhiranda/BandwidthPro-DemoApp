import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Concepts'),
        backgroundColor: Colors.blue[600],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildConceptCard(
            title: 'Bandwidth',
            description: 'Bandwidth represents the maximum rate of data transfer across a network. It is typically measured in bits per second (bps), kilobits per second (Kbps), megabits per second (Mbps), or gigabits per second (Gbps).',
            icon: Icons.speed,
          ),
          _buildConceptCard(
            title: 'Network Congestion',
            description: 'Network congestion occurs when a network node or link carries more data than it can handle. Typical effects include queueing delay, packet loss, and the blocking of new connections.',
            icon: Icons.traffic,
          ),
          _buildConceptCard(
            title: 'Latency',
            description: 'Latency is the delay before a transfer of data begins following an instruction for its transfer. In networks, it represents the time it takes for a packet to travel from source to destination.',
            icon: Icons.timer,
          ),
          _buildConceptCard(
            title: 'Quality of Service (QoS)',
            description: 'QoS refers to the capability of a network to provide better service to selected network traffic. This involves prioritizing certain types of data traffic, like video calls or online gaming, over others.',
            icon: Icons.high_quality,
          ),
          _buildConceptCard(
            title: 'Packet Loss',
            description: 'Packet loss occurs when data packets traveling across a network fail to reach their destination. This can be caused by network congestion, hardware failure, or signal degradation.',
            icon: Icons.warning,
          ),
          _buildConceptCard(
            title: 'Jitter',
            description: 'Jitter is the variation in the delay of received packets. High jitter can result in degraded call quality in VoIP applications or buffering in video streaming.',
            icon: Icons.waves,
          ),
          _buildConceptCard(
            title: 'Traffic Patterns',
            description: 'Different applications generate different traffic patterns:\n\n- Constant: Steady stream of packets (e.g., video streaming)\n- Burst: Short bursts of high activity (e.g., web browsing)\n- Incremental: Gradually increasing load (e.g., file downloads)\n- Random: Unpredictable patterns (e.g., online gaming)',
            icon: Icons.timeline,
          ),
          _buildConceptCard(
            title: 'Ethical Network Testing',
            description: 'Network testing must be conducted responsibly and ethically. Key principles include:\n\n'
                '• Only test networks you own or have permission to test\n'
                '• Consider the impact on other network users\n'
                '• Schedule tests during off-peak hours when possible\n'
                '• Set reasonable limits on test duration and intensity\n'
                '• Never use testing tools to intentionally disrupt services',
            icon: Icons.shield,
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


