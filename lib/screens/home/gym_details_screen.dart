import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';

class GymDetailsScreen extends StatefulWidget {
  final String gymId;

  const GymDetailsScreen({Key? key, required this.gymId}) : super(key: key);

  @override
  State<GymDetailsScreen> createState() => _GymDetailsScreenState();
}

class _GymDetailsScreenState extends State<GymDetailsScreen> {
  Map<String, dynamic>? _gym;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGymDetails();
  }

  Future<void> _loadGymDetails() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getGymDetails(widget.gymId);
    if (response['success']) {
      setState(() {
        _gym = response['data']['gym'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubscribe(String tierId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ApiService.createSubscriptionSession(
      gymId: widget.gymId,
      tierId: tierId,
    );

    Navigator.pop(context);

    if (response['success']) {
      final sessionUrl = response['data']['url'];
      if (sessionUrl != null) {
        final uri = Uri.parse(sessionUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? 'Failed to create session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gym Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gym == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gym Details')),
        body: const Center(child: Text('Gym not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_gym!['name'] ?? 'Gym Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gym header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gym!['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _gym!['location'] ?? 'No location',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  if (_gym!['description'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _gym!['description'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ],
              ),
            ),

            // Membership plans
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Membership Plans',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_gym!['tiers'] != null &&
                      (_gym!['tiers'] as List).isNotEmpty)
                    ...(_gym!['tiers'] as List).map((tier) {
                      return _buildTierCard(tier);
                    }).toList()
                  else
                    const Text('No membership plans available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(Map<String, dynamic> tier) {
    final price = tier['price'] ?? 0;
    final duration = tier['durationDays'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tier['name'] ?? 'Unnamed Plan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$price',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '$duration days',
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
            if (tier['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                tier['description'],
                style: const TextStyle(fontSize: 15),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSubscribe(tier['_id']),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
