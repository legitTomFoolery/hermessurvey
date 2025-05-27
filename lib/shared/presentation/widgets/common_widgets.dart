import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import '../../../app/config/app_constants.dart';

/// Collection of commonly used widgets throughout the application
class CommonWidgets {
  // Private constructor to prevent instantiation
  CommonWidgets._();

  /// Standard app bar with consistent styling
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    bool automaticallyImplyLeading = true,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading ?? (automaticallyImplyLeading ? null : Container()),
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              title,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  /// Standard logout button for app bars
  static Widget buildLogoutButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return SizedBox(
      width: 48,
      child: IconButton(
        icon: Icon(
          Icons.logout,
          color: theme.colorScheme.onPrimary,
          size: AppConstants.appBarIconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }

  /// Standard floating action button
  static Widget buildFloatingActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    IconData icon = Icons.add,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  /// Standard progress bar
  static Widget buildProgressBar({
    required BuildContext context,
    required double progress,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: theme.colorScheme.tertiary,
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      minHeight: AppConstants.progressBarHeight,
    );
  }

  /// Standard elevated button with consistent styling
  static Widget buildElevatedButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return SizedBox(
      width: width,
      height: height ?? AppConstants.defaultButtonHeight.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ??
              (onPressed != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.tertiary),
          disabledBackgroundColor: theme.colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// Standard text button with consistent styling
  static Widget buildTextButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    TextStyle? textStyle,
    Color? backgroundColor,
    double? width,
    double? height,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textStyle?.color ?? theme.colorScheme.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.buttonHorizontalPadding.w,
          vertical: AppConstants.buttonVerticalPadding.h,
        ),
      ),
      child: Text(
        text,
        style: textStyle ?? TextStyle(color: theme.colorScheme.primary),
      ),
    );
  }

  /// Standard text form field with consistent styling
  static Widget buildTextFormField({
    required BuildContext context,
    required String hint,
    Widget? suffixIcon,
    FocusNode? focusNode,
    Function(String)? onChanged,
    bool isObscureText = false,
    bool isDense = true,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return TextFormField(
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.shadow),
        isDense: isDense,
        filled: true,
        fillColor: theme.colorScheme.secondary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.textFieldHorizontalPadding.w,
          vertical: AppConstants.textFieldVerticalPadding.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.surface,
            width: AppConstants.textFieldBorderWidth.w,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: AppConstants.textFieldBorderWidth.w,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.shadow,
            width: AppConstants.textFieldBorderWidth.w,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: AppConstants.textFieldBorderWidth.w,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: isObscureText,
      style: TextStyle(color: theme.colorScheme.shadow),
    );
  }

  /// Standard loading indicator
  static Widget buildLoadingIndicator({
    required BuildContext context,
    String? message,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Standard error display with retry option
  static Widget buildErrorView({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback onRetry,
    String retryText = AppConstants.retryText,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultSpacing * 2),
            buildElevatedButton(
              context: context,
              text: retryText,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  /// Standard empty state display
  static Widget buildEmptyState({
    required BuildContext context,
    required String message,
    IconData icon = Icons.inbox_outlined,
    Widget? action,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: theme.colorScheme.shadow,
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.shadow,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppConstants.defaultSpacing * 2),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Standard card container with consistent styling
  static Widget buildCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: AppConstants.defaultSpacing / 2,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
        child: child,
      ),
    );
  }
}
