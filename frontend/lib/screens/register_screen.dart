import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/invoiz_logo.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleInitial = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _birthday = TextEditingController();
  final _street = TextEditingController();

  String? _sex;
  DateTime? _birthDate;

  // PSGC (Philippine Standard Geographic Code) API data.
  List _provinces = [];
  List _municipalities = [];
  List _barangays = [];
  String? _provinceCode;
  String? _municipalityCode;
  String? _provinceName;
  String? _municipalityName;
  String? _barangayName;
  bool _loadingAddress = false;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _loadingAddress = true);
    try {
      final res = await http.get(Uri.parse('${AppConfig.psgcBaseUrl}/provinces'));
      final data = jsonDecode(res.body) as List;
      setState(() {
        _provinces = data;
        _loadingAddress = false;
      });
    } catch (_) {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _loadMunicipalities() async {
    setState(() {
      _municipalities = [];
      _barangays = [];
      _municipalityCode = null;
      _municipalityName = null;
      _barangayName = null;
    });
    try {
      final res = await http.get(Uri.parse('${AppConfig.psgcBaseUrl}/provinces/$_provinceCode/municipalities'));
      final data = jsonDecode(res.body) as List;
      setState(() => _municipalities = data);
    } catch (_) {}
  }

  Future<void> _loadBarangays() async {
    setState(() {
      _barangays = [];
      _barangayName = null;
    });
    try {
      final res = await http.get(Uri.parse('${AppConfig.psgcBaseUrl}/municipalities/$_municipalityCode/barangays'));
      final data = jsonDecode(res.body) as List;
      setState(() => _barangays = data);
    } catch (_) {}
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthday.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  int _calcAge(DateTime b) {
    final now = DateTime.now();
    var age = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) age--;
    return age;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _show('Please select your birthday.');
      return;
    }
    if (_provinceName == null || _municipalityName == null || _barangayName == null) {
      _show('Please complete your address (Province, Municipality, Barangay).');
      return;
    }

    setState(() => _busy = true);
    try {
      final api = ApiService();

      await api.postForm('register', {
        'last_name': _lastName.text.trim(),
        'first_name': _firstName.text.trim(),
        'middle_initial': _middleInitial.text.trim(),
        'sex': _sex ?? '',
        'email': _email.text.trim(),
        'password': _password.text,
        'password_confirmation': _passwordConfirm.text,
        'phone': _phone.text.trim(),
        'birthday': _birthday.text,
        'province': _provinceName ?? '',
        'municipality': _municipalityName ?? '',
        'barangay': _barangayName ?? '',
        'address_line': _street.text.trim(),
      });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Registration Submitted'),
          content: const Text(
            'After submitting your registration, please wait for the administrator\'s approval, '
            'which will be sent to your email.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _middleInitial.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _birthday.dispose();
    _street.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Hero(
                    tag: 'invoiz_logo',
                    child: InvoizLogo.logoWidget(size: 88, radius: 24),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Register as a buyer to start shopping',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Personal Information'),
                  _field('Last name*', _lastName, icon: Icons.person, required: true),
                  _field('First name*', _firstName, icon: Icons.person_outline, required: true),
                  _field('Middle initial', _middleInitial, icon: Icons.person_pin),
                  const SizedBox(height: 12),
                  Text('Sex*', style: _labelStyle()),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sex,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.wc)),
                    items: ['male', 'female', 'other']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _sex = v),
                    validator: (v) => v == null ? 'Select sex' : null,
                  ),
                  const SizedBox(height: 12),
                  _field('E-mail*', _email, icon: Icons.email_outlined, required: true, keyboard: TextInputType.emailAddress),
                  _field('Contact No.*', _phone, icon: Icons.phone_outlined, required: true, keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickBirthday,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Birthday*',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      child: Text(_birthday.text.isEmpty ? 'YYYY-MM-DD' : _birthday.text),
                    ),
                  ),
                  if (_birthDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Age (auto): ${_calcAge(_birthDate!)}',
                        style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  _field('Password*', _password, icon: Icons.lock_outline, obscure: true, required: true),
                  _field('Confirm Password*', _passwordConfirm, icon: Icons.lock, obscure: true, required: true,
                      confirmWith: _password),

                  const SizedBox(height: 18),
                  _sectionTitle('Address (Philippine Standard Geographic Code)'),
                  _addressDropdown('Province', _provinceName, _provinces, (v) {
                    setState(() {
                      _provinceCode = v;
                      _provinceName = _provinces.firstWhere((p) => p['code'] == v)['name'] as String;
                      _loadMunicipalities();
                    });
                  }),
                  _addressDropdown('Municipality', _municipalityName, _municipalities, (v) {
                    setState(() {
                      _municipalityCode = v;
                      _municipalityName = _municipalities.firstWhere((m) => m['code'] == v)['name'] as String;
                      _loadBarangays();
                    });
                  }),
                  _addressDropdown('Barangay', _barangayName, _barangays, (v) {
                    setState(() {
                      _barangayName = _barangays.firstWhere((b) => b['code'] == v)['name'] as String;
                    });
                  }),
                  _field('Street / House no. / etc.', _street, icon: Icons.home_outlined),
                  if (_loadingAddress) const LinearProgressIndicator(),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    child: _busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Registration', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'After submitting your registration, please wait for the administrator\'s approval, which will be sent to your email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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

  TextStyle _labelStyle() =>
      TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500);

  Widget _field(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool required = false,
    bool obscure = false,
    TextInputType? keyboard,
    TextEditingController? confirmWith,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, prefixIcon: icon != null ? Icon(icon) : null),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Required';
          if (confirmWith != null && v != confirmWith.text) return 'Passwords do not match';
          if (label.toLowerCase().contains('e-mail') && v != null && v.isNotEmpty) {
            if (!v.contains('@')) return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _addressDropdown(
    String label,
    String? value,
    List items,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value != null
            ? items.firstWhere((i) => i['name'] == value, orElse: () => {'code': ''})['code']
            : null,
        hint: Text(label),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
        isExpanded: true,
        items: items
            .map<DropdownMenuItem<String>>(
                (i) => DropdownMenuItem(value: i['code'] as String, child: Text(i['name'] as String, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
