import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';
import 'add_address_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _addressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAddressCount();
  }

  Future<void> _loadAddressCount() async {
    try {
      final data = await ApiService().get('addresses');
      if (mounted) {
        setState(() => _addressCount = (data['addresses'] as List).length);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthServiceProvider.of(context);
    final user = auth.user;

    return MainLayout(
      currentIndex: 4,
      showSettingsIcon: false,
      title: 'Account',
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (user?.firstName ?? '?').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(user?.email ?? '', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${_shortDate(user?.birthday)}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _menuTile(Icons.receipt_long_outlined, 'My Orders', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          _menuTile(Icons.location_on_outlined, 'My Addresses ($_addressCount)', () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
            _loadAddressCount();
          }),
          _menuTile(Icons.person_outline, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    auth.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  String _shortDate(String? iso) {
    if (iso == null || iso.isEmpty) return 'Invoiz';
    try {
      final d = DateTime.parse(iso);
      return '${d.year}';
    } catch (_) {
      return 'Invoiz';
    }
  }
}
