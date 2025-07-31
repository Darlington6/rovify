// lib/presentation/screens/auth/signup_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/core/widgets/custom_button.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_bottom_sheet.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';


class SignUpBottomSheet extends StatefulWidget {
  const SignUpBottomSheet({super.key});

  @override
  State<SignUpBottomSheet> createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
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

  void _submitSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must agree to the terms and conditions to continue.")),
        );
        return;
      }

      // Trigger Bloc Event
      context.read<AuthBloc>().add(SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        acceptedTerms: _agreeToTerms,
      )
      );
    }
  }
  void showSignUpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignUpBottomSheet(),
    );
  }

  // void showSignUpBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (sheetContext) {
  //   return BlocListener<AuthBloc, AuthState>(
  //     listener: (context, state) {
  //       if (state is AuthError) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(state.message),
  //             backgroundColor: Colors.amber, // Gentle color for information and guidance
  //             // behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       } else if (state is Authenticated) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Account created successfully!"),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         Navigator.of(context).pop(); // Close bottom sheet
  //       }
  //     },
  //     child: const SignUpBottomSheet(),
  //     );
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
      return Container(
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
                  padding: const EdgeInsets.only(top: 48), // Leaves space for close button
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
                              "Welcome to Rovify",
                              style: TextStyle(fontSize: 28, color: Color(0xFF000000), fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Create your account to start discovering amazing events and collecting unforgettable memories",
                            style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                          ),
                          const SizedBox(height: 24),
                
                          // Social Sign In Buttons
                          CustomButton.icon(
                            text: "Continue with Google",
                            icon: Image.asset('assets/icons/google.png', height: 20, width: 20,),
                            onPressed: () {
                              if (!_agreeToTerms) {
                                Navigator.of(context).pop(); // Close the bottom sheet first
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please check the box to accept the TOS & Privacy Policy before continuing with Google.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.red), // Red color to indicate requirement
                                      ),
                                    backgroundColor: Colors.amber, // Gentle color for guidance
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                                return; // Don't proceed to sign up
                              }
                              // Terms accepted, continue with Google sign-in
                              context.read<AuthBloc>().add(GoogleSignInRequested());
                            },
                          ),
                
                          const SizedBox(height: 12),
                
                          CustomButton.icon(
                            text: "Continue with Apple",
                            icon: Image.asset('assets/icons/apple.png', height: 30, width: 30,),
                            onPressed: () async {
                              Navigator.of(context).pop(); // Close bottom sheet
                                await Future.delayed(Duration(milliseconds: 100)); // Give time for context rebuild
                                if (!context.mounted) return; // Only proceed if the widget is still mounted
                                context.read<AuthBloc>().add(AppleSignInRequested());
                            }
                          ),
                
                          const SizedBox(height: 12),
                
                          CustomButton.icon(
                            text: "Continue with X",
                            icon: Image.asset('assets/icons/x.png', height: 30, width: 30,),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close bottom sheet
                              context.read<AuthBloc>().add(XSignInRequested());
                            }
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
                              validator: (value) { // Added here for the time being. Full validation will be handled later
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
                                hintText: "Create a password",
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
                                  return "Password is required";
                                }

                                final password = value.trim();

                                if (password.length < 8) {
                                  return "Password must be at least 8 characters";
                                }

                                if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
                                  return "Must include at least one uppercase letter";
                                }

                                if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
                                  return "Must include at least one lowercase letter";
                                }

                                if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
                                  return "Must include at least one number";
                                }

                                if (!RegExp(r'(?=.*[^A-Za-z0-9])').hasMatch(password)) {
                                  return "Must include at least one special character";
                                }

                                return null;
                              },
                            ),
                          ),
                
                          const SizedBox(height: 20),
                
                          // Terms and Policy Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (val) => setState(() => _agreeToTerms = val!),
                              ),
                              Flexible(
                                child: Wrap(
                                  children: [
                                    const Text("I agree to the ", style: TextStyle(color: Color(0xFF757575), fontSize: 16,),),
                                    InkWell(
                                      onTap: () async {
                                        // Open a URL or navigate in app
                                        final Uri url = Uri.parse('https://example.com/terms'); // To be replaced with the actual URL
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication); // In this case, open an external site
                                        }
                                      },
                                      child: const Text(
                                        "Terms of Service",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Color(0xFF757575),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                
                                    const Text(" and ", style: TextStyle(color: Color(0xFF757575), fontSize: 16,),),
                                    InkWell(
                                      onTap: () async {
                                        // Open a URL or navigate in app
                                        final Uri url = Uri.parse('https://example.com/terms'); // To be replaced with the actual URL
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication); // In this case, open an external site
                                        }
                                      },
                                      child: const Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Color(0xFF757575),
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                
                          const SizedBox(height: 20),
                
                          // Create Account Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              return ElevatedButton(
                                onPressed: _agreeToTerms && !isLoading ? _submitSignUp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _agreeToTerms
                                      ? const Color(0xFF000000)
                                      : const Color(0xFFBDBDBD),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? Center(
                                      child: const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                    )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Center(
                                            child: Text(
                                              "Create Account",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const Positioned(
                                            right: 0,
                                            child: Icon(
                                              Icons.arrow_forward,
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
                
                          // Toggle to Login
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Close signup
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const LoginBottomSheet(),
                                );
                              },
                              child: const Text.rich(
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
                                  children: [
                                    TextSpan(
                                      text: "Login",
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
      );
  }
}