import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _collegeEmailController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _coordinatorLocalController = TextEditingController();
  final _domainController = TextEditingController();
  final _collegeNameController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  String? _selectedCollege;
  String? _selectedDomain;
  bool _usePersonalEmail = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loadingColleges = true;
  List<Map<String, String>> _colleges = [];

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.collegesCollection)
          .get();

      final items = snapshot.docs.map((d) {
        final data = d.data();
        final name = (data['name'] ?? d.id).toString();
        final domain = (data['domain'] ?? '').toString();
        return {'name': name, 'domain': domain};
      }).toList();

      if (mounted) {
        setState(() {
          _colleges = items;
          _loadingColleges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _colleges = [];
          _loadingColleges = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _collegeEmailController.dispose();
    _personalEmailController.dispose();
    _coordinatorLocalController.dispose();
    _domainController.dispose();
    _collegeNameController.dispose();
    super.dispose();
  }

  void _updateEmailField() {
    if (_selectedRole == UserRole.coordinator) {
      final local = _coordinatorLocalController.text.trim();
      final domain = _domainController.text.trim().replaceAll(RegExp(r'^@+'), '');
      _selectedDomain = domain;
      _emailController.text = (local.isNotEmpty && domain.isNotEmpty)
          ? '$local@$domain'
          : '';
      return;
    }

    if (_selectedCollege != null && _selectedDomain != null && !_usePersonalEmail) {
      final domain = _selectedDomain!;
      _emailController.text = '${_collegeEmailController.text}@$domain';
    } else if (_usePersonalEmail) {
      _emailController.text = _personalEmailController.text;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    String email = _emailController.text.trim();
    String? personalEmail = _usePersonalEmail ? _personalEmailController.text.trim() : null;
    
    final error = await authProvider.signUp(
      email: email,
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
      collegeName: _selectedCollege,
      collegeDomain: _selectedDomain,
      personalEmail: personalEmail,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_usePersonalEmail 
              ? 'Registration successful! Please wait for approval.'
              : 'Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Role Selection
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.where((role) => role != UserRole.admin).map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      _selectedCollege = null;
                      _selectedDomain = null;
                      _usePersonalEmail = false;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // College Selection (for coordinator role)
                if (_selectedRole == UserRole.coordinator) ...[
                  CustomTextField(
                    controller: _collegeNameController,
                    label: 'College Name',
                    prefixIcon: Icons.school,
                    onChanged: (value) {
                      setState(() {
                        _selectedCollege = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter college name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Coordinator email local-part and domain side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _coordinatorLocalController,
                          label: 'Email (before @)',
                          prefixIcon: Icons.alternate_email,
                          onChanged: (value) => setState(_updateEmailField),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter email ID';
                            }
                            if (value.contains('@') || value.contains(' ')) {
                              return 'Do not include @ or spaces';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _domainController,
                          label: 'Domain (e.g., example.edu)',
                          prefixIcon: Icons.domain,
                          onChanged: (value) => setState(_updateEmailField),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) return 'Enter domain';
                            final clean = v.replaceAll(RegExp(r'^@+'), '');
                            final domainRegex = RegExp(r'^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                            if (!domainRegex.hasMatch(clean)) {
                              return 'Invalid domain';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // College Selection for other roles
                  DropdownButtonFormField<String>(
                    value: _selectedCollege,
                    decoration: const InputDecoration(
                      labelText: 'Select College',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    items: _loadingColleges
                        ? []
                        : _colleges.map((college) {
                            return DropdownMenuItem(
                              value: college['name'],
                              child: Text(college['name']!),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCollege = value;
                        _selectedDomain = _colleges
                            .firstWhere((college) => college['name'] == value, orElse: () => {'domain': ''})['domain'];
                        _updateEmailField();
                      });
                    },
                    validator: (value) {
                      if (_loadingColleges) {
                        return 'Loading colleges...';
                      }
                      if (value == null || value.isEmpty) {
                        return 'Please select a college';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Personal Email Checkbox
                  CheckboxListTile(
                    title: const Text("Don't have a college email ID"),
                    value: _usePersonalEmail,
                    onChanged: (value) {
                      setState(() {
                        _usePersonalEmail = value ?? false;
                        _updateEmailField();
                      });
                    },
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Email Fields
                if (_selectedRole == UserRole.coordinator) ...[
                  CustomTextField(
                    controller: _emailController,
                    label: 'Composed Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    readOnly: true,
                    validator: (value) {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) return 'Enter email and domain';
                      final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$').hasMatch(email);
                      if (!ok) return 'Email is badly formatted';
                      return null;
                    },
                  ),
                ] else if (!_usePersonalEmail) ...[
                  CustomTextField(
                    controller: _collegeEmailController,
                    label: 'College Email (without @${_selectedDomain ?? 'domain'})',
                    prefixIcon: Icons.email,
                    onChanged: (value) => _updateEmailField(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your college email';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  CustomTextField(
                    controller: _personalEmailController,
                    label: 'Personal Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    onChanged: (value) => _updateEmailField(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Register',
                      onPressed: authProvider.isLoading ? null : _register,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
                
                // Approval Notice
                if (_usePersonalEmail) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your account will require approval before you can login.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}