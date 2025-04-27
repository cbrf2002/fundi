import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/circle_gradient_background.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStatusBar();
  }

  void _configureStatusBar() {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent resize when keyboard appears to avoid background distortion
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const CircleGradientBackground(),
          Center(
            // Wrap the Padding/Column with SingleChildScrollView
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    LoginHeader(),
                    SizedBox(height: 24), // Add some spacing if needed
                    LoginFormContainer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
