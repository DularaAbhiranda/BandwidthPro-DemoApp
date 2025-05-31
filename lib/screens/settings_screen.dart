import 'package:flutter/material.dart';
import '../models/test_config.dart';

class SettingsScreen extends StatefulWidget {
  final TestConfig config;
  final Function(TestConfig) onConfigUpdated;

  const SettingsScreen({
    Key? key,
    required this.config,
    required this.onConfigUpdated,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _packetSizeController;
  late TextEditingController _requestFrequencyController;
  late TextEditingController _testDurationController;
  late String _selectedProtocol;
  late TrafficPattern _selectedPattern;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config.name);
    _packetSizeController = TextEditingController(text: widget.config.packetSize.toString());
    _requestFrequencyController = TextEditingController(text: widget.config.requestFrequency.toString());
    _testDurationController = TextEditingController(text: widget.config.testDuration.toString());
    _selectedProtocol = widget.config.protocol;
    _selectedPattern = widget.config.pattern;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _packetSizeController.dispose();
    _requestFrequencyController.dispose();
    _testDurationController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final updatedConfig = TestConfig(
        name: _nameController.text,
        packetSize: int.parse(_packetSizeController.text),
        requestFrequency: int.parse(_requestFrequencyController.text),
        testDuration: int.parse(_testDurationController.text),
        protocol: _selectedProtocol,
        pattern: _selectedPattern,
      );

      widget.onConfigUpdated(updatedConfig);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Settings'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Test Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Traffic Pattern
            DropdownButtonFormField<TrafficPattern>(
              decoration: const InputDecoration(
                labelText: 'Traffic Pattern',
                border: OutlineInputBorder(),
              ),
              value: _selectedPattern,
              items: TrafficPattern.values.map((pattern) {
                return DropdownMenuItem(
                  value: pattern,
                  child: Text(pattern.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPattern = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Protocol Selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Protocol',
                border: OutlineInputBorder(),
              ),
              value: _selectedProtocol,
              items: ['HTTP', 'POST', 'TCP', 'UDP'].map((protocol) {
                return DropdownMenuItem(
                  value: protocol,
                  child: Text(protocol),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProtocol = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Packet Size
            TextFormField(
              controller: _packetSizeController,
              decoration: const InputDecoration(
                labelText: 'Packet Size (bytes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a packet size';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 64 || int.parse(value) > 8192) {
                  return 'Packet size must be between 64 and 8192 bytes';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Request Frequency
            TextFormField(
              controller: _requestFrequencyController,
              decoration: const InputDecoration(
                labelText: 'Request Frequency (per second)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a frequency';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 1 || int.parse(value) > 50) {
                  return 'Frequency must be between 1 and 50';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Test Duration
            TextFormField(
              controller: _testDurationController,
              decoration: const InputDecoration(
                labelText: 'Test Duration (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a duration';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 5 || int.parse(value) > 300) {
                  return 'Duration must be between 5 and 300 seconds';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}