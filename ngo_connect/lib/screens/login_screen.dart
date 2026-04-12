import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/firebase_service.dart';
import 'ngo/ngo_dashboard.dart';
import 'volunteer/volunteer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _keepMeLoggedIn = false;
  bool _isLoading = false;
  String _selectedRole = 'volunteer';

  // ── Common controllers ────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // ── NGO-specific controllers ──────────────────────────────────────────────
  final _ngoTypeController = TextEditingController();
  final _ngoAddressController = TextEditingController();
  final _ngoContactEmailController = TextEditingController();
  final _coordinatorNameController = TextEditingController();
  final _coordinatorAddressController = TextEditingController();

  // NGO type options
  static const _ngoTypes = [
    'Education',
    'Medical',
    'Environment',
    'Food & Nutrition',
    'Disaster Relief',
    'Women Empowerment',
    'Child Welfare',
    'Animal Welfare',
    'Community Development',
    'Other',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ngoTypeController.dispose();
    _ngoAddressController.dispose();
    _ngoContactEmailController.dispose();
    _coordinatorNameController.dispose();
    _coordinatorAddressController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns a non-null error string if any required field is blank.
  /// Requirement 1.4: display field-level validation error and prevent submission.
  String? _validateRegistrationFields() {
    if (_nameController.text.trim().isEmpty) return 'Full name is required.';
    if (_emailController.text.trim().isEmpty) return 'Email is required.';
    if (_passwordController.text.trim().isEmpty) return 'Password is required.';

    if (_selectedRole == 'ngo') {
      if (_ngoTypeController.text.trim().isEmpty) return 'NGO type is required.';
      if (_ngoAddressController.text.trim().isEmpty) return 'NGO address is required.';
      if (_ngoContactEmailController.text.trim().isEmpty) return 'Contact email is required.';
      if (_coordinatorNameController.text.trim().isEmpty) return 'Coordinator name is required.';
      if (_coordinatorAddressController.text.trim().isEmpty) {
        return 'Coordinator address is required.';
      }
    }
    return null;
  }

  // ── Auth Logic ────────────────────────────────────────────────────────────

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_isLogin) {
        result = await FirebaseService.login(email, password);
      } else {
        // Validate all required fields before attempting registration.
        final validationError = _validateRegistrationFields();
        if (validationError != null) {
          _showError(validationError);
          setState(() => _isLoading = false);
          return;
        }

        // Build NGO-specific data payload when role is 'ngo'.
        // Requirement 1.1: insert into `ngos` with all provided fields.
        // Requirement 1.2: geocoding is handled inside FirebaseService.createOrUpdateNgo.
        Map<String, dynamic>? ngoData;
        if (_selectedRole == 'ngo') {
          ngoData = {
            'name': name,
            'type': _ngoTypeController.text.trim(),
            'address': _ngoAddressController.text.trim(),
            'contactEmail': _ngoContactEmailController.text.trim(),
            'coordinatorName': _coordinatorNameController.text.trim(),
            'coordinatorAddress': _coordinatorAddressController.text.trim(),
          };
        }

        result = await FirebaseService.register(
          name,
          email,
          password,
          _selectedRole,
          ngoData: ngoData,
        );
      }

      if (result.containsKey('error')) {
        _showError(result['error']);
      } else {
        final role = result['role'] ?? 'volunteer';
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                role == 'ngo' ? const NgoDashboard() : const VolunteerDashboard(),
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      );

  Widget _gap([double h = 20]) => SizedBox(height: h);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'NGO Connect',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                _gap(32),

                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                _gap(8),
                Text(
                  _isLogin
                      ? 'Enter your credentials to access your dashboard'
                      : 'Join thousands of changemakers today',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                _gap(48),

                // ── Main Card ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGrey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildToggle(),
                      _gap(32),
                      if (!_isLogin) ..._buildSignUpFields(),
                      _buildEmailField(),
                      _gap(),
                      _buildPasswordField(),
                      _gap(16),
                      if (_isLogin) _buildKeepLoggedIn(),
                      _gap(24),
                      _buildSubmitButton(),
                      _gap(32),
                      _buildSocialDivider(),
                      _gap(24),
                      _buildSocialButtons(),
                    ],
                  ),
                ),

                _gap(32),
                _buildFooterBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleTab('Login', _isLogin, () => setState(() => _isLogin = true)),
          _toggleTab(
              'Sign Up', !_isLogin, () => setState(() => _isLogin = false)),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: active
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSignUpFields() {
    return [
      // ── Full Name ──────────────────────────────────────────────────────
      _fieldLabel('Full Name'),
      _gap(8),
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          hintText: 'John Doe',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      _gap(),

      // ── Role selector ──────────────────────────────────────────────────
      _fieldLabel('I am a'),
      _gap(8),
      _buildRoleSelector(),
      _gap(),

      // ── NGO-specific fields ────────────────────────────────────────────
      if (_selectedRole == 'ngo') ..._buildNgoFields(),
    ];
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        _roleButton('Volunteer', 'volunteer'),
        const SizedBox(width: 12),
        _roleButton('NGO', 'ngo'),
      ],
    );
  }

  Widget _roleButton(String label, String role) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryPurple),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// NGO-specific registration fields.
  /// Requirement 1.1: name, type, address, contactEmail, coordinatorName + address.
  List<Widget> _buildNgoFields() {
    return [
      // Divider to visually separate NGO section
      const Divider(height: 32),
      Text(
        'Organization Details',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryPurple,
        ),
      ),
      _gap(16),

      // NGO Type (dropdown)
      _fieldLabel('Organization Type *'),
      _gap(8),
      DropdownButtonFormField<String>(
        value: _ngoTypeController.text.isEmpty ? null : _ngoTypeController.text,
        hint: const Text('Select type'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.category_outlined),
        ),
        items: _ngoTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (val) {
          if (val != null) setState(() => _ngoTypeController.text = val);
        },
      ),
      _gap(),

      // NGO Address (geocoded on submit — Requirement 1.2)
      _fieldLabel('Organization Address *'),
      _gap(8),
      TextFormField(
        controller: _ngoAddressController,
        decoration: const InputDecoration(
          hintText: '123 Main St, City, Country',
          prefixIcon: Icon(Icons.location_on_outlined),
        ),
      ),
      _gap(),

      // Contact Email
      _fieldLabel('Contact Email *'),
      _gap(8),
      TextFormField(
        controller: _ngoContactEmailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'contact@ngo.org',
          prefixIcon: Icon(Icons.mail_outline),
        ),
      ),
      _gap(),

      // Coordinator section
      const Divider(height: 32),
      Text(
        'Field Coordinator',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryPurple,
        ),
      ),
      _gap(4),
      Text(
        'The coordinator point is shown to volunteers on task cards.',
        style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
      ),
      _gap(16),

      // Coordinator Name
      _fieldLabel('Coordinator Name *'),
      _gap(8),
      TextFormField(
        controller: _coordinatorNameController,
        decoration: const InputDecoration(
          hintText: 'Jane Smith',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
      ),
      _gap(),

      // Coordinator Address (geocoded on submit — Requirement 1.2)
      _fieldLabel('Coordinator Address *'),
      _gap(8),
      TextFormField(
        controller: _coordinatorAddressController,
        decoration: const InputDecoration(
          hintText: '456 Field Office Rd, City, Country',
          prefixIcon: Icon(Icons.place_outlined),
        ),
      ),
      _gap(),
    ];
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Email Address'),
        _gap(8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'name@company.com',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('Password'),
            if (_isLogin)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('Forgot password?',
                    style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        _gap(8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
      ],
    );
  }

  Widget _buildKeepLoggedIn() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _keepMeLoggedIn,
            onChanged: (val) => setState(() => _keepMeLoggedIn = val!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        const Text('Keep me logged in',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAuth,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_isLogin ? 'Sign In' : 'Sign Up'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
                fontSize: 12, color: AppTheme.textGrey, letterSpacing: 0.5),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata, size: 24),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.code, size: 20),
            label: const Text('GitHub'),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('For Change Makers',
                    style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Your skills can change lives. Complete your profile after signup to get instant recommendations for active social projects.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textGrey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
