// // lib/screens/signup_screen.dart
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../widgets/custom_text_field.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _name = '';
//   String _email = '';
//   String _password = '';
//   String _accountType = 'user';
//   bool _loading = false;

//   void _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     setState(() => _loading = true);
//     try {
//       await AuthService().signUp(
//         email: _email,
//         password: _password,
//         name: _name,
//         accountType: _accountType,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Account created successfully')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     }
//     if (mounted) {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 CustomTextField(
//                   labelText: 'Name',
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _name = val?.trim() ?? '',
//                 ),
//                 CustomTextField(
//                   labelText: 'Email',
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _email = val?.trim() ?? '',
//                 ),
//                 CustomTextField(
//                   labelText: 'Password',
//                   obscureText: true,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     if (val.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _password = val?.trim() ?? '',
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _accountType,
//                   items: [
//                     DropdownMenuItem(value: 'user', child: Text('User')),
//                     DropdownMenuItem(value: 'admin', child: Text('Admin')),
//                   ],
//                   onChanged: (val) => setState(() => _accountType = val!),
//                   decoration: InputDecoration(
//                     labelText: 'Account Type',
//                     helperText: 'Note: Admin accounts need verification',
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 _loading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: _submit, child: Text('Sign Up')),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _accountType = 'user';
  bool _loading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await AuthService().signUp(
        email: _email,
        password: _password,
        name: _name,
        accountType: _accountType,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your GiggleSeat account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    CustomTextField(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (val) => _name = val?.trim() ?? '',
                    ),
                    
                    CustomTextField(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (val) => _email = val?.trim() ?? '',
                    ),
                    
                    CustomTextField(
                      labelText: 'Password',
                      hintText: 'Choose a strong password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onSaved: (val) => _password = val?.trim() ?? '',
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Account Type Selection with a more modern style
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Type',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              _buildAccountTypeOption(
                                context: context,
                                title: 'User',
                                subtitle: 'Book tickets for shows and events',
                                icon: Icons.person,
                                value: 'user',
                              ),
                              SizedBox(width: 16),
                              _buildAccountTypeOption(
                                context: context,
                                title: 'Admin',
                                subtitle: 'Manage shows and tickets',
                                icon: Icons.admin_panel_settings,
                                value: 'admin',
                              ),
                            ],
                          ),
                          if (_accountType == 'admin')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Note: Admin accounts require verification',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    _loading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7.0),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                    
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _accountType == value;
    
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _accountType = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}