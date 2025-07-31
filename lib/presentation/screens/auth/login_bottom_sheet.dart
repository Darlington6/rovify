// lib/presentation/screens/auth/login_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/core/widgets/custom_button.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_event.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(_scrollToField);
    _passwordFocusNode.addListener(_scrollToField);
  }

  void _scrollToField() {
    if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      // Delay to wait until keyboard is fully visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  // void _submitLogin() {
  //   if (_formKey.currentState!.validate()) {
  //     // Dispatch login event to Bloc
  //     context.read<AuthBloc>().add(
  //           SignInRequested(
  //             email: _emailController.text.trim(),
  //             password: _passwordController.text,
  //           ),
  //         );
  //   }
  // }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      // Dispatch login event to Bloc
      context.read<AuthBloc>().add(SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }

  void showSignUpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const LoginBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Welcome back!")),
          );
          Navigator.pop(context); // Close bottom sheet
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85, // Set height of bottom sheet
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Scrollable content below the close button
                Padding(
                  padding: const EdgeInsets.only(top: 28), // Leaves space for close button

              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                        CustomButton.icon(
                          text: "Continue with Google",
                          icon: Image.asset('assets/icons/google.png', height: 20, width: 20,),
                          // icon: Icon(Icons.g_mobiledata, size: 20,),
                          onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                        ),
                
                        const SizedBox(height: 12),
                
                        CustomButton.icon(
                          text: "Continue with Apple",
                          // icon: const Icon(Icons.apple, color: Colors.black, size: 28,),
                          icon: Image.asset('assets/icons/apple.png', height: 30, width: 30,),
                          onPressed: () => context.read<AuthBloc>().add(AppleSignInRequested()),
                        ),
                
                        const SizedBox(height: 12),
                
                        CustomButton.icon(
                          text: "Continue with X",
                          // icon: const Icon(Icons.close, color: Colors.black, size: 27,),
                          icon: Image.asset('assets/icons/x.png', height: 30, width: 30,),
                          onPressed: () => context.read<AuthBloc>().add(XSignInRequested()),
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
                          decoration: BoxDecoration(
                            color: Colors.white, // White background like the other buttons
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                            color: Color(0xFF757575),
                          ),
                          ),
                          child: TextFormField(
                            focusNode: _emailFocusNode,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "youremail@example.com",
                              hintStyle: TextStyle(fontSize: 18,  color: Color(0xFF757575),),
                              border: InputBorder.none, // Remove default underline
                              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12,), // Add spacing between characters and the input field (box)
                            ),
                            validator: (value) {
                              if (value == null || !value.contains("@")) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                        ),
                
                        const SizedBox(height: 20),
                
                        // Password Input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // White background like the other buttons
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                            color: Color(0xFF757575),
                          ),
                          ),
                          child: TextFormField(
                            focusNode: _passwordFocusNode,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              hintText: "Enter a password",
                              hintStyle: const TextStyle(fontSize: 18,  color: Color(0xFF757575),),
                              border: InputBorder.none, // Remove default underline
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12,), // Add spacing to the top and bottom, and between characters and the input field (box)
                              suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }

                              if (value.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              return null;
                            },
                          ),
                        ),
                
                        const SizedBox(height: 20),
                
                        // Sign In Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: (state is AuthLoading) ? null : _submitLogin, // Disables button when loading
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                backgroundColor: Color(0xFF000000),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // If loading, show spinner
                                  if (state is AuthLoading)
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Center(
                                      child: Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                  // Arrow Icon (always visible on right)
                                  const Positioned(
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