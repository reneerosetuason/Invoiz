import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/main_layout.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = ApiService();
  List<Order> _orders = [];
  bool _loading = true;
  String _status = 'all';

  static const _tabs = [
    ('all', 'All'),
    ('pending', 'To Ship'),
    ('out_for_delivery', 'In Transit'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final query = _status != 'all' ? {'status': _status} : null;
      final data = await _api.get('orders', query: query);
      setState(() {
        _orders = (data['orders'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'To Ship';
      case 'confirmed':
      case 'processing':
      case 'ready_for_delivery':
        return 'Processing';
      case 'out_for_delivery':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return Colors.red;
      case 'out_for_delivery':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'My Orders',
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: _tabs.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.$2),
                    selected: _status == t.$1,
                    onSelected: (_) {
                      setState(() => _status = t.$1);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text('No orders found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _orderCard(_orders[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Order order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final otherCount = order.items.length - 1;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(fontSize: 11, color: _statusColor(order.status), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (firstItem != null)
              Row(
                children: [
                  Text(
                    firstItem.productName,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (otherCount > 0)
                    Text(' +$otherCount more', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Total: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Text(
                  _fmt(order.totalAmount),
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  _date(order.createdAt),
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final n = v.toStringAsFixed(2);
    return 'â‚±${n.split('.')[0]}.${n.split('.')[1]}';
  }

  String _date(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
