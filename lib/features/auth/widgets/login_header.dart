import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode ? 'lib/assets/logo/logoDark.svg' : 'lib/assets/logo/logoLight.svg';

    return Column(
      children: [
        SvgPicture.asset(
          logoPath,
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 48),
        Text(
          'Easily track your expenses and make smart financial decisions with Fundi.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
