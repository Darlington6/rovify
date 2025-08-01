// lib/presentation/screens/auth/login_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rovify/core/widgets/custom_button.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_event.dart';
import 'package:rovify/presentation/screens/auth/forgotpassword_bottom_sheet.dart';
import 'signup_bottom_sheet.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _emailKey = GlobalKey();    // Used to scroll to email field
  final _passwordKey = GlobalKey(); // Used to scroll to password field

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    // Listen to focus changes and scroll into view if field is focused
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) _scrollToField(_emailKey);
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) _scrollToField(_passwordKey);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Scrolls to a specific field using its GlobalKey
  void _scrollToField(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Toggles password visibility
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }  

  void _submitLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool isValid = true;

    // Email validation
    if (email.isEmpty) {
      setState(() => _emailError = "Email is required.");
      isValid = false;
    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      setState(() => _emailError = "Please enter a valid email address.");
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    // Password validation
    if (password.isEmpty) {
      setState(() => _passwordError = "Password is required.");
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    // Dispatch signup event
    if (isValid) {
      context.read<AuthBloc>().add(SignInRequested(
            email: email,
            password: password,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst); // Remove bottom sheet
          context.go('/onboarding'); // Then go to onboarding screen
        }
      },
    
      child: Container(
            height: MediaQuery.of(context).size.height * 0.85, // Set height of bottom sheet
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Scrollable content below the close button
                  Padding(
                    padding: const EdgeInsets.only(top: 48), // Leaves space for close button

                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                  
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  
                          // Title and subtitle
                          Center(
                            child: const Text(
                              "Welcome back!",
                              style: TextStyle(fontSize: 28, color: Color(0xFF000000), fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Log in to continue exploring events and your saved moments",
                            style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                  
                          // Social Sign In Buttons
                          
                          // Google Sign In
                          CustomButton.icon(
                            text: "Continue with Google",
                            icon: Image.asset('assets/icons/google.png', height: 20, width: 20,),
                            onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                          ),
                  
                          const SizedBox(height: 12),

                          // Apple Sign In
                          CustomButton.icon(
                            text: "Continue with Apple",
                            icon: Image.asset('assets/icons/apple.png', height: 30, width: 30,),
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(AppleSignInRequested());
                            },
                          ),
                  
                          const SizedBox(height: 12),
                  
                          CustomButton.icon(
                            text: "Continue with X",
                            icon: Image.asset('assets/icons/x.png', height: 30, width: 30,),
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<AuthBloc>().add(XSignInRequested());
                            },
                          ),
                  
                          const SizedBox(height: 20),
                  
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFF757575),
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "Or",
                                  style: TextStyle(color: Color(0xFF757575)),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFF757575),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                  
                          const SizedBox(height: 20),
                  
                          // Email Input
                          Container(
                            key: _emailKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_emailError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(_emailError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF757575)),
                                  ),
                                  child: TextFormField(
                                    focusNode: _emailFocusNode,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: "youremail@example.com",
                                      hintStyle: TextStyle(fontSize: 18, color: Color(0xFF757575)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() => _emailError = null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  
                          const SizedBox(height: 20),
                  
                          // Password Input
                          Container(
                            key: _passwordKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_passwordError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(_passwordError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF757575)),
                                  ),
                                  child: TextFormField(
                                    focusNode: _passwordFocusNode,
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      hintText: "Create a password",
                                      hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF757575)),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                    ),
                                    onChanged: (_) => setState(() => _passwordError = null),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (ctx) => ForgotPasswordBottomSheet(),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot Password?", 
                                      style: TextStyle(color: Color(0xFFFF5900)),
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  
                          const SizedBox(height: 20),
                  
                          // Sign In Button with BloC state
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              return ElevatedButton(
                                onPressed: (state is AuthLoading) ? null : _submitLogin, // Disables button when loading
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  backgroundColor: Color(0xFF000000),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: const [
                                          Center(
                                            child: Text(
                                              "Sign In",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: Icon(
                                              Icons.arrow_forward, // Right-pointing arrow
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                  
                          const SizedBox(height: 24),
                  
                          // Toggle to Sign Up
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Close login
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const SignUpBottomSheet(),
                                );
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: "Don't have an account yet? ",
                                  style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                        color: Color(0xFFFF5900),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Close (X) Button fixed at the top-right
              Positioned(
                top: -10.0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}