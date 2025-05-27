import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/common_widgets.dart';
import '../../../../../app/config/app_constants.dart';

/// A reusable error view widget that displays an error message and a retry button
class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String? retryText;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return CommonWidgets.buildErrorView(
      context: context,
      errorMessage: errorMessage,
      onRetry: onRetry,
      retryText: retryText ?? AppConstants.retryText,
    );
  }
}
