import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/app/config/app_constants.dart';

void main() {
  group('CommonWidgets', () {
    testWidgets('buildElevatedButton creates button with correct text',
        (WidgetTester tester) async {
      const buttonText = 'Test Button';
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildElevatedButton(
              context: tester.element(find.byType(Scaffold)),
              text: buttonText,
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify button text
      expect(find.text(buttonText), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify button was pressed
      expect(buttonPressed, true);
    });

    testWidgets('buildTextFormField creates field with correct hint',
        (WidgetTester tester) async {
      const hintText = 'Enter your email';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildTextFormField(
              context: tester.element(find.byType(Scaffold)),
              hint: hintText,
            ),
          ),
        ),
      );

      // Verify hint text
      expect(find.text(hintText), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('buildLoadingIndicator shows circular progress indicator',
        (WidgetTester tester) async {
      const loadingMessage = 'Loading...';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildLoadingIndicator(
              context: tester.element(find.byType(Scaffold)),
              message: loadingMessage,
            ),
          ),
        ),
      );

      // Verify loading indicator and message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(loadingMessage), findsOneWidget);
    });

    testWidgets('buildErrorView shows error message and retry button',
        (WidgetTester tester) async {
      const errorMessage = 'Something went wrong';
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildErrorView(
              context: tester.element(find.byType(Scaffold)),
              errorMessage: errorMessage,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify error message and retry button
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text(AppConstants.retryText), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text(AppConstants.retryText));
      await tester.pump();

      // Verify retry was called
      expect(retryPressed, true);
    });

    testWidgets('buildEmptyState shows empty message and icon',
        (WidgetTester tester) async {
      const emptyMessage = 'No items found';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildEmptyState(
              context: tester.element(find.byType(Scaffold)),
              message: emptyMessage,
            ),
          ),
        ),
      );

      // Verify empty state message and default icon
      expect(find.text(emptyMessage), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('buildCard creates container with child',
        (WidgetTester tester) async {
      const childText = 'Card Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildCard(
              context: tester.element(find.byType(Scaffold)),
              child: const Text(childText),
            ),
          ),
        ),
      );

      // Verify card contains child
      expect(find.text(childText), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('buildProgressBar shows linear progress indicator',
        (WidgetTester tester) async {
      const progress = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonWidgets.buildProgressBar(
              context: tester.element(find.byType(Scaffold)),
              progress: progress,
            ),
          ),
        ),
      );

      // Verify progress bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, progress);
    });
  });
}
