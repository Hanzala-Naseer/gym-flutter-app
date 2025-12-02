import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade100,
                child:
                    Icon(Icons.person, size: 60, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                icon: Icons.person,
                title: 'Name',
                value: user?['name'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.email,
                title: 'Email',
                value: user?['email'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.phone,
                title: 'Phone',
                value: user?['phone'] ?? 'N/A',
              ),
              _buildInfoCard(
                icon: Icons.verified_user,
                title: 'Account Status',
                value:
                    user?['isVerified'] == true ? 'Verified' : 'Not Verified',
                valueColor:
                    user?['isVerified'] == true ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),
              if (user?['subscriptions'] != null &&
                  (user!['subscriptions'] as List).isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Active Subscriptions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...(user['subscriptions'] as List).map((sub) {
                  return _buildSubscriptionCard(sub);
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription['gymId']?['name'] ?? 'Gym',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: subscription['status'] == 'active'
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription['status'] ?? 'Unknown',
                    style: TextStyle(
                      color: subscription['status'] == 'active'
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tier: ${subscription['tierId']?['name'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (subscription['endDate'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: ${_formatDate(subscription['endDate'])}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
