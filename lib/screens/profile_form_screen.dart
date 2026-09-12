import 'package:flutter/material.dart';
import 'package:office_app/models/user_model.dart';
import 'package:office_app/services/firestore_service.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/custom_widgets.dart';

class ProfileFormScreen extends StatefulWidget {
  final UserProfile? profile;
  const ProfileFormScreen({super.key, this.profile});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _designationController;
  late TextEditingController _companyController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.displayName ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phoneNumber ?? '');
    _designationController = TextEditingController(text: widget.profile?.designation ?? '');
    _companyController = TextEditingController(text: widget.profile?.companyName ?? '');
    _bioController = TextEditingController(text: widget.profile?.bio ?? '');

    if (widget.profile == null) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await FirestoreService.getUserProfileFuture();
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile.displayName;
          _emailController.text = profile.email;
          _phoneController.text = profile.phoneNumber;
          _designationController.text = profile.designation;
          _companyController.text = profile.companyName;
          _bioController.text = profile.bio;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedProfile = UserProfile(
        uid: widget.profile?.uid ?? FirestoreService.currentUserId ?? '',
        displayName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        designation: _designationController.text,
        companyName: _companyController.text,
        bio: _bioController.text,
        photoUrl: widget.profile?.photoUrl ?? '',
      );

      await FirestoreService.updateUserProfile(updatedProfile);
      
      if (mounted) {
        // Provide haptic-like scroll to top? Just kidding, just show success.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile Updated Successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Small delay for better UX before popping
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [AppTheme.backgroundColor, const Color(0xFF1E1B4B)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF3F4F6)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            hint: 'Enter your full name',
                            validator: (v) => v!.isEmpty ? 'Name is required' : null,
                          ),
                          _buildTextField(
                            controller: _designationController,
                            label: 'Designation / Role',
                            icon: Icons.badge_outlined,
                            hint: 'e.g. IT Asset Manager',
                          ),
                          _buildTextField(
                            controller: _companyController,
                            label: 'Company Name',
                            icon: Icons.business_outlined,
                            hint: 'Enter your company name',
                          ),
                          
                          const SizedBox(height: 32),
                          _buildSectionTitle('Contact Details'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                          ),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 32),
                          _buildSectionTitle('About Me'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _bioController,
                            label: 'Short Bio',
                            icon: Icons.info_outline_rounded,
                            maxLines: 4,
                          ),
                          
                          const SizedBox(height: 48),
                          _buildSaveButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Personal Information',
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the back button
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: textColor, fontSize: 15),
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 13),
              hintText: hint,
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.2)),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
