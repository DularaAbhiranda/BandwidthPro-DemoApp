import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _ownershipAcknowledged = false;
  bool _responsibleUseAcknowledged = false;
  bool _educationalPurposeAcknowledged = false;

  Future<void> _acceptTerms() async {
    if (_ownershipAcknowledged && _responsibleUseAcknowledged && _educationalPurposeAcknowledged) {
      // Save that user has accepted terms
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('terms_accepted', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must acknowledge all terms to continue'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Responsible Use Agreement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BandwidthPro is an educational tool designed to help understand network behavior under load. To ensure ethical and legal use of this application, please read and agree to the following terms:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            _buildTermsCard(
              title: 'Network Ownership',
              content: 'I confirm that I will only use this application on networks that I own or have explicit permission to test.',
              isChecked: _ownershipAcknowledged,
              onChanged: (value) {
                setState(() {
                  _ownershipAcknowledged = value ?? false;
                });
              },
            ),

            _buildTermsCard(
              title: 'Responsible Usage',
              content: 'I understand that using this application on public networks or networks without permission may be illegal and unethical. I will use this tool responsibly and with consideration for other network users.',
              isChecked: _responsibleUseAcknowledged,
              onChanged: (value) {
                setState(() {
                  _responsibleUseAcknowledged = value ?? false;
                });
              },
            ),

            _buildTermsCard(
              title: 'Educational Purpose',
              content: 'I acknowledge that this application is intended for educational and diagnostic purposes only, not for disrupting network services or causing harm to network infrastructure.',
              isChecked: _educationalPurposeAcknowledged,
              onChanged: (value) {
                setState(() {
                  _educationalPurposeAcknowledged = value ?? false;
                });
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Legal Notice: Misuse of this application may violate computer fraud, abuse laws, and telecommunication regulations in many jurisdictions. Users are solely responsible for ensuring their use complies with all applicable laws and regulations.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptTerms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'I Accept The Terms',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard({
    required String title,
    required String content,
    required bool isChecked,
    required Function(bool?) onChanged,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: onChanged,
                ),
                const Text(
                  'I acknowledge and agree',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}