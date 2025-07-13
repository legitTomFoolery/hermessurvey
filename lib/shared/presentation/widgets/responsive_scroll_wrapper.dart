import 'package:flutter/material.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';

/// A wrapper widget that provides responsive scrolling behavior
/// Allows scrolling across full width while constraining content width
class ResponsiveScrollWrapper extends StatelessWidget {
  final Widget child;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ResponsiveScrollWrapper({
    super.key,
    required this.child,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const ClampingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
