import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';

class SellerApplyScreen extends StatefulWidget {
  const SellerApplyScreen({super.key});

  @override
  State<SellerApplyScreen> createState() => _SellerApplyScreenState();
}

class _SellerApplyScreenState extends State<SellerApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();

  String? _lineOfBusiness;
  XFile? _idImage;
  XFile? _permit;

  List _categories = [];
  bool _loadingCats = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCats = true);
    try {
      final data = await ApiService().get('categories');
      setState(() {
        _categories = (data['categories'] as List).cast<Map<String, dynamic>>();
        _loadingCats = false;
      });
    } catch (_) {
      setState(() => _loadingCats = false);
    }
  }

  @override
  void dispose() {
    _businessName.dispose();
    super.dispose();
  }

  Future<void> _pickFile({required bool isId}) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked == null) return;
    setState(() {
      if (isId) {
        _idImage = picked;
      } else {
        _permit = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineOfBusiness == null) {
      _show('Please select your line of business.');
      return;
    }
    if (_idImage == null) {
      _show('Please upload a valid ID.');
      return;
    }
    if (_permit == null) {
      _show('Please upload your business permit.');
      return;
    }

    setState(() => _busy = true);
    try {
      final files = <http.MultipartFile>[];
      if (_idImage != null) {
        final bytes = await _idImage!.readAsBytes();
        files.add(http.MultipartFile.fromBytes('id_image', bytes, filename: _idImage!.name));
      }
      if (_permit != null) {
        final bytes = await _permit!.readAsBytes();
        files.add(http.MultipartFile.fromBytes('business_permit', bytes, filename: _permit!.name));
      }

      final api = ApiService();
      await api.postForm('seller/apply', {
        'business_name': _businessName.text.trim(),
        'line_of_business': _lineOfBusiness!,
      }, files: files);

      if (!mounted) return;
      await AuthServiceProvider.of(context).refreshUser();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Application Submitted'),
          content: const Text(
            'Your seller application has been submitted. Please wait for the '
            'administrator\'s approval, which will be sent to your email. '
            'Once approved, you can start selling with the same account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      _show(e.message);
    } catch (_) {
      _show('Unable to connect to server.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthServiceProvider.of(context).user;
    return MainLayout(
      title: 'Apply as Seller',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, color: AppColors.primary, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your account can act as a buyer and a seller at the same time. '
                      'Once approved, you can switch between them anytime.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Your Information'),
            if (user != null) ...[
              _infoRow(Icons.person_outline, 'Name', '${user.firstName} ${user.lastName}'),
              _infoRow(Icons.mail_outline, 'E-mail', user.email),
              _infoRow(Icons.phone_outlined, 'Contact No.', user.phone ?? 'â€”'),
              _infoRow(Icons.cake_outlined, 'Birthday / Age', '${user.birthday ?? 'â€”'} (${user.age ?? 'â€”'} y/o)'),
              _infoRow(Icons.location_on_outlined, 'Address',
                  [user.barangay, user.municipality, user.province, user.addressLine]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(', ')),
            ],
            const SizedBox(height: 20),
            _sectionTitle('Business Details'),
            TextFormField(
              controller: _businessName,
              decoration: const InputDecoration(
                labelText: 'Business name*',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _lineOfBusiness,
              decoration: const InputDecoration(
                labelText: 'Line of business (category)*',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c['name'] as String, child: Text(c['name'] as String)))
                  .toList(),
              onChanged: (v) => setState(() => _lineOfBusiness = v),
              validator: (v) => v == null ? 'Select line of business' : null,
            ),
            if (_loadingCats) const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Documents'),
            _uploadTile(
              icon: Icons.badge_outlined,
              title: 'Valid ID',
              file: _idImage,
              onTap: () => _pickFile(isId: true),
            ),
            const SizedBox(height: 12),
            _uploadTile(
              icon: Icons.description_outlined,
              title: 'Business permit',
              file: _permit,
              onTap: () => _pickFile(isId: false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Application'),
            ),
            const SizedBox(height: 12),
            Text(
              'After submitting your application, please wait for the administrator\'s approval, '
              'which will be sent to your email.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required IconData icon,
    required String title,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    final filled = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: filled ? AppColors.success : AppColors.border, width: filled ? 1.4 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: filled ? AppColors.success : AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filled ? file.name : '$title*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                  color: filled ? AppColors.success : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              filled ? Icons.check_circle : Icons.upload_file,
              color: filled ? AppColors.success : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
