import 'package:flutter/material.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';

/// A simple loading view with a centered circular progress indicator
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return CommonWidgets.buildLoadingIndicator(
      context: context,
      message: message,
    );
  }
}
