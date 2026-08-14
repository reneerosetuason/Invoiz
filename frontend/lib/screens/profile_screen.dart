import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/auth_service_provider.dart';
import '../widgets/main_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleInitial = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _province = TextEditingController();
  final _municipality = TextEditingController();
  final _barangay = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  String? _sex;
  XFile? _idImage;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = AuthServiceProvider.of(context).user;
    if (user != null) {
      _lastName.text = user.lastName;
      _firstName.text = user.firstName;
      _middleInitial.text = user.middleInitial ?? '';
      _phone.text = user.phone ?? '';
      _street.text = user.addressLine ?? '';
      _province.text = user.province ?? '';
      _municipality.text = user.municipality ?? '';
      _barangay.text = user.barangay ?? '';
      _sex = user.sex;
    }
  }

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _middleInitial.dispose();
    _phone.dispose();
    _street.dispose();
    _province.dispose();
    _municipality.dispose();
    _barangay.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) setState(() => _idImage = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.isNotEmpty && _password.text != _passwordConfirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final api = ApiService();
      final files = <http.MultipartFile>[];
      if (_idImage != null) {
        final bytes = await _idImage!.readAsBytes();
        files.add(http.MultipartFile.fromBytes('id_image', bytes, filename: _idImage!.name));
      }
      await api.postForm('profile', {
        'last_name': _lastName.text.trim(),
        'first_name': _firstName.text.trim(),
        'middle_initial': _middleInitial.text.trim(),
        'sex': _sex ?? '',
        'phone': _phone.text.trim(),
        'province': _province.text.trim(),
        'municipality': _municipality.text.trim(),
        'barangay': _barangay.text.trim(),
        'address_line': _street.text.trim(),
        if (_password.text.isNotEmpty) 'password': _password.text,
        if (_password.text.isNotEmpty) 'password_confirmation': _passwordConfirm.text,
      }, files: files);

      await AuthServiceProvider.of(context).refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Edit Profile',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Last name*'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'First name*'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _middleInitial, decoration: const InputDecoration(labelText: 'Middle initial')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(labelText: 'Sex'),
              items: ['male', 'female', 'other']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: (v) => setState(() => _sex = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Contact No.'),
            ),
            const Divider(height: 30),
            const Text('Address', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            TextFormField(controller: _province, decoration: const InputDecoration(labelText: 'Province')),
            const SizedBox(height: 12),
            TextFormField(controller: _municipality, decoration: const InputDecoration(labelText: 'Municipality')),
            const SizedBox(height: 12),
            TextFormField(controller: _barangay, decoration: const InputDecoration(labelText: 'Barangay')),
            const SizedBox(height: 12),
            TextFormField(controller: _street, decoration: const InputDecoration(labelText: 'Street / House no.')),
            const Divider(height: 30),
            const Text('Change Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password (leave blank to keep)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordConfirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
            const Divider(height: 30),
            const Text('Identification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(_idImage == null ? Icons.upload_file : Icons.check_circle,
                        color: _idImage == null ? AppColors.textSecondary : AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _idImage == null ? 'Upload new ID (optional)' : _idImage!.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              child: _busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}