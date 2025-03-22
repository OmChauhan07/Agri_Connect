import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';

class ConsumerProfileScreen extends StatefulWidget {
  const ConsumerProfileScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerProfileScreen> createState() => _ConsumerProfileScreenState();
}

class _ConsumerProfileScreenState extends State<ConsumerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  XFile? _profileImage;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await authProvider.uploadProfileImage(_profileImage!);
      }

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        profileImage: profileImageUrl ?? user.profileImage,
      );

      await authProvider.updateUserProfile(updatedUser);

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();

      if (!mounted) return;

      // Navigate to login screen using MaterialPageRoute
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (user == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Picture & Edit Button
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Profile Image
                            GestureDetector(
                              onTap: _isEditing ? _pickImage : null,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _profileImage != null
                                    ? FileImage(File(_profileImage!.path))
                                    : user.profileImage != null
                                        ? NetworkImage(user.profileImage!)
                                            as ImageProvider
                                        : null,
                                child: user.profileImage == null &&
                                        _profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            // Edit Indicator
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.name ?? 'Consumer',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Role
                        const Text(
                          'Consumer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Edit/Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_isEditing) {
                                      _updateProfile();
                                    } else {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing
                                  ? AppColors.primary
                                  : Colors.grey[200],
                              foregroundColor:
                                  _isEditing ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                                _isEditing ? 'Save Profile' : 'Edit Profile'),
                          ),
                        ),
                        if (_isEditing)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                                _profileImage = null;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Form
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                              filled: !_isEditing,
                              fillColor: _isEditing ? null : Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Field (non-editable)
                          TextFormField(
                            initialValue: user.email,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Field
                          TextFormField(
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.phone),
                              filled: !_isEditing,
                              fillColor: _isEditing ? null : Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address Field
                          TextFormField(
                            controller: _addressController,
                            enabled: _isEditing,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Delivery Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.location_on),
                              filled: !_isEditing,
                              fillColor: _isEditing ? null : Colors.grey[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Other Settings
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Settings List
                        ListTile(
                          leading: const Icon(Icons.shopping_bag,
                              color: AppColors.primary),
                          title: const Text('My Orders'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // Navigate to orders screen
                            Navigator.pushNamed(context, '/orders');
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.favorite,
                              color: AppColors.primary),
                          title: const Text('Favorite Farmers'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: Implement favorites screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Favorites feature coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading:
                              const Icon(Icons.lock, color: AppColors.primary),
                          title: const Text('Change Password'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: Implement change password screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Change password feature coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.language,
                              color: AppColors.primary),
                          title: const Text('Language'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('English'),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: Implement language selection
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Language selection coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications,
                              color: AppColors.primary),
                          title: const Text('Notification Settings'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: Implement notification settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Notification settings coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading:
                              const Icon(Icons.help, color: AppColors.primary),
                          title: const Text('Help & Support'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            // TODO: Implement help & support
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Help & support coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading:
                              const Icon(Icons.exit_to_app, color: Colors.red),
                          title: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Version Info
                  Center(
                    child: Text(
                      'AgriConnect v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
