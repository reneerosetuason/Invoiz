import 'package:flutter/material.dart';
import '../models/address.dart';
import '../models/cart.dart';
import '../models/voucher.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/main_layout.dart';
import 'add_address_screen.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiService();
  Cart? _cart;
  List<Address> _addresses = [];
  List<Voucher> _vouchers = [];
  int? _selectedAddressId;
  String? _selectedVoucher;
  double? _validatedDiscount;
  String _paymentMethod = 'cash_on_delivery';
  bool _loading = true;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cartData = await _api.get('cart');
      final addrData = await _api.get('addresses');
      final voucherData = await _api.get('vouchers');
      setState(() {
        _cart = Cart.fromJson(cartData);
        _addresses = (addrData['addresses'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Address.fromJson)
            .toList();
        _vouchers = (voucherData['vouchers'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Voucher.fromJson)
            .toList();
        if (_selectedAddressId == null && _addresses.isNotEmpty) {
          final def = _addresses.where((a) => a.isDefault).firstOrNull ?? _addresses.first;
          _selectedAddressId = def.id;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _applyVoucher(String code) async {
    try {
      final r = await _api.post('vouchers/validate', {
        'code': code,
        'subtotal': _cart?.subtotal ?? 0,
      });
      setState(() {
        _selectedVoucher = code;
        _validatedDiscount = double.tryParse('${r['discount']}') ?? 0;
      });
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _placing = true);
    try {
      await _api.post('orders/checkout', {
        'address_id': _selectedAddressId,
        'payment_method': _paymentMethod,
        'voucher_code': _selectedVoucher,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully! (Cash on Delivery)'), backgroundColor: AppColors.success),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to place order.'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Checkout',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cart == null || _cart!.items.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _section('Shipping Address', _addressSection(context)),
                    const SizedBox(height: 8),
                    _section('Payment Method', _paymentSection()),
                    const SizedBox(height: 8),
                    _section('Voucher', _voucherSection()),
                    const SizedBox(height: 8),
                    _section('Order Summary', _summarySection()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _placing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: _placing
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Place Order (Cash on Delivery)', style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _addressSection(BuildContext context) {
    if (_addresses.isEmpty) {
      return Column(
        children: [
          const Text('No saved addresses yet.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
              _load();
            },
            child: const Text('Add Address'),
          ),
        ],
      );
    }
    return Column(
      children: [
        ..._addresses.map((a) {
          return RadioListTile<int>(
            value: a.id,
            groupValue: _selectedAddressId,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _selectedAddressId = v),
            title: Text(a.recipientName, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              '${a.phone}\n${a.fullAddress}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
              _load();
            },
          ),
        ),
      ],
    );
  }

  Widget _paymentSection() {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'cash_on_delivery',
          groupValue: _paymentMethod,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _paymentMethod = v!),
          title: const Text('Cash on Delivery (COD)', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Pay when your order arrives.', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _voucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedVoucher != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher: $_selectedVoucher', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Discount: -${_fmt(_validatedDiscount ?? 0)}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    _selectedVoucher = null;
                    _validatedDiscount = null;
                  }),
                ),
              ],
            ),
          ),
        if (_vouchers.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vouchers.map((v) {
              return ActionChip(
                avatar: const Icon(Icons.local_offer, size: 16, color: AppColors.primary),
                label: Text(v.code),
                onPressed: () => _applyVoucher(v.code),
              );
            }).toList(),
          )
        else
          const Text('No active vouchers.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _summarySection() {
    final subtotal = _cart!.subtotal;
    final discount = _validatedDiscount ?? 0;
    final total = subtotal - discount;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal', style: TextStyle(fontSize: 13)),
            Text(_fmt(subtotal), style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Voucher Discount', style: TextStyle(fontSize: 13)),
            Text('-${_fmt(discount)}', style: const TextStyle(fontSize: 13, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shipping', style: TextStyle(fontSize: 13)),
            Text(discount > 0 ? 'FREE' : 'Calculated on delivery', style: const TextStyle(fontSize: 13)),
          ],
        ),
        const Divider(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              _fmt(total),
              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(double v) {
    final n = v.toStringAsFixed(2);
    return '₱${n.split('.')[0]}.${n.split('.')[1]}';
  }
}