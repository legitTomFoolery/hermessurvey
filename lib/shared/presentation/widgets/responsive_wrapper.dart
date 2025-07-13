import 'package:flutter/material.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';

/// A wrapper widget that constrains content to a phone-like width
/// and centers it horizontally for better display on larger screens
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
