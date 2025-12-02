import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _gyms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    setState(() => _isLoading = true);
    final response = await ApiService.getAllGyms();
    if (response['success']) {
      setState(() {
        _gyms = response['data']['gyms'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGymsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gyms.isEmpty) {
      return const Center(
        child: Text('No gyms available', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGyms,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gyms.length,
        itemBuilder: (context, index) {
          final gym = _gyms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/gym-details',
                  arguments: {'gymId': gym['_id']},
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym['name'] ?? 'Unnamed Gym',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            gym['location'] ?? 'No location',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    if (gym['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        gym['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${gym['tiers']?.length ?? 0} Plans',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 50, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 16),
          Text(
            user?['name'] ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user?['email'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildProfileOption(
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            onTap: () => Navigator.pushNamed(context, '/qr-scanner'),
          ),
          _buildProfileOption(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          _buildProfileOption(
            icon: Icons.card_membership,
            title: 'My Subscriptions',
            onTap: () {
              // Navigate to subscriptions screen
            },
          ),
          _buildProfileOption(
            icon: Icons.history,
            title: 'Check-in History',
            onTap: () {
              // Navigate to history screen
            },
          ),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () async {
              await authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Gyms' : 'Profile'),
      ),
      body: _selectedIndex == 0 ? _buildGymsTab() : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gyms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
