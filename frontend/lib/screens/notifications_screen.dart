import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/main_layout.dart';
import 'order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('notifications');
      setState(() {
        _items = (data['notifications'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Notifications',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 10),
                      Text('No notifications yet.', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _item(_items[i]),
                  ),
                ),
    );
  }

  Widget _item(Map<String, dynamic> n) {
    final type = n['type'] as String;
    final orderId = n['order_id'] as int?;
    final read = n['read'] as bool? ?? false;

    final IconData icon;
    final Color color;
    switch (type) {
      case 'review':
        icon = Icons.star_outline;
        color = AppColors.gold;
        break;
      default:
        icon = Icons.local_shipping_outlined;
        color = AppColors.primary;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: orderId != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
              )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: read ? AppColors.card : AppColors.accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: read ? AppColors.border : AppColors.primary.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['body'] as String,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(n['created_at'] as String),
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
